import Dispatch
import HTTP
import Foundation

class ContextThread : Thread {
    let request: Request
    let block: (() throws -> Response)
    let semaphore = DispatchSemaphore(value: 0)
    var result: Response? = nil
    var error: Swift.Error? = nil
    
    init(for request: Request, block: @escaping (() throws -> Response)) {
        self.request = request
        self.block = block
        super.init()
        self.start()
    }
    
    override func main() {
        defer { semaphore.signal() }
        
        do {
            self.result = try block()
        } catch {
            self.error = error
        }
    }
    
    func await() throws -> Response {
        let timeout = DispatchTime(secondsFromNow: 30)
        
        guard semaphore.wait(timeout: timeout) == .success else {
            throw ContextAwarenessMiddleware.Error.timeout(after: timeout)
        }
        
        guard let result = result else {
            throw error ?? ContextAwarenessMiddleware.Error.strangeInconsistency
        }
        
        return result
    }
}

extension Request {
    public static var current: Request? {
        return (Thread.current as? ContextThread)?.request
    }
}

public class ContextAwarenessMiddleware : Middleware {
    public enum Error : Swift.Error {
        case strangeInconsistency
        case timeout(after: DispatchTime)
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let thread = ContextThread(for: request) {
            return try next.respond(to: request)
        }
        
        return try thread.await()
    }
}
