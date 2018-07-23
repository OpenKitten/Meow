import NIO

public enum MeowHooks {
    public typealias Hook<M> = (M, Context) throws -> EventLoopFuture<Void>
    
    private static var presaveHooks = [Any]()
    
    /// Registers a new presave hook on the given model.
    /// Presave hooks are called before every save operation.
    ///
    /// When a presave hook throws, or when the future returned from a presave hook fails, the save
    /// operation is cancelled and the error is passed through to the caller of the `Model.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPresaveHook<M: Model>(_ handler: @escaping Hook<M>) {
        presaveHooks.append(handler)
    }
    
    internal static func callPresaveHooks<M: Model>(on instance: M, context: Context) -> EventLoopFuture<Void> {
        return callHooks(presaveHooks, on: instance, context: context)
    }
    
    /// Calls the given `hooks` on the `instance`
    private static func callHooks<M: Model>(_ hooks: [Any], on instance: M, context: Context) -> EventLoopFuture<Void> {
        var futures = [EventLoopFuture<Void>]()
        
        for hook in hooks.compactMap({ $0 as? Hook<M> }) {
            do {
                try futures.append(hook(instance, context))
            } catch {
                return context.eventLoop.newFailedFuture(error: error)
            }
        }
        
        return EventLoopFuture<Void>.andAll(futures, eventLoop: context.eventLoop)
    }
}
