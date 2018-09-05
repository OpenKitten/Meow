import NIO

public enum MeowHooks {
    public typealias Hook<M> = (M, Context) throws -> EventLoopFuture<Void>
    
    // A wrapper around a hook. Hooks are wrapped like this so hooks are possible on protocols and not just a single type of model.
    private struct WrappedHook {
        var hook: (Any, Context) throws -> EventLoopFuture<Void>
        var typeCheck: (Any.Type) -> Bool
    }
    
    private static var presaveHooks = [WrappedHook]()
    private static var postsaveHooks = [WrappedHook]()
    private static var predeleteHooks = [WrappedHook]()
    private static var postdeleteHooks = [WrappedHook]()
    
    private static func wrapHook<T>(on hookType: T.Type = T.self, handler: @escaping Hook<T>) -> WrappedHook {
        let typeCheck: (Any.Type) -> Bool = { candidate in
            return candidate is T.Type
        }
        
        let anyHook: (Any, Context) throws -> EventLoopFuture<Void> = { instance, context in
            guard let instance = instance as? T else {
                return context.eventLoop.newSucceededFuture(result: ())
            }
            
            return try handler(instance, context)
        }
        
        return WrappedHook(hook: anyHook, typeCheck: typeCheck)
    }
    
    /// Registers a new presave hook on the given model or protocol.
    /// Presave hooks are called before every save operation.
    ///
    /// When a presave hook throws, or when the future returned from a presave hook fails, the save
    /// operation is cancelled and the error is passed through to the caller of the `Context.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPresaveHook<T>(on hookType: T.Type, handler: @escaping Hook<T>) {
        presaveHooks.append(wrapHook(handler: handler))
    }
    
    /// Registers a new postsave hook on the given model or protocol.
    /// Postsave hooks are called after every save operation.
    ///
    /// When a postsave hook throws, or when the future returned from a postsave hook fails, the error is passed through to the caller of the `Context.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPostsaveHook<T>(on hookType: T.Type, handler: @escaping Hook<T>) {
        presaveHooks.append(wrapHook(handler: handler))
    }
    
    /// Registers a new predelete hook on the given model or protocol.
    /// Presave hooks are called before delete save operation.
    ///
    /// When a predelete hook throws, or when the future returned from a predelete hook fails, the delete
    /// operation is cancelled and the error is passed through to the caller of the `Context.delete` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPredeleteHook<T>(on hookType: T.Type, handler: @escaping Hook<T>) {
        predeleteHooks.append(wrapHook(handler: handler))
    }
    
    /// Registers a new postdelete hook on the given model or protocol.
    /// Presave hooks are called before delete save operation.
    ///
    /// When a postdelete hook throws, or when the future returned from a postsave hook fails, the error is passed through to the caller of the `Context.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPostdeleteHook<T>(on hookType: T.Type, handler: @escaping Hook<T>) {
        postdeleteHooks.append(wrapHook(handler: handler))
    }
    
    internal static func callPresaveHooks<M: Model>(on instance: M, context: Context) -> EventLoopFuture<Void> {
        return callHooks(presaveHooks, on: instance, context: context)
    }
    
    internal static func callPostsaveHooks<M: Model>(on instance: M, context: Context) -> EventLoopFuture<Void> {
        return callHooks(postsaveHooks, on: instance, context: context)
    }
    
    internal static func callPredeleteHooks<M: Model>(on instance: M, context: Context) -> EventLoopFuture<Void> {
        return callHooks(predeleteHooks, on: instance, context: context)
    }
    
    internal static func callPostdeleteHooks<M: Model>(on instance: M, context: Context) -> EventLoopFuture<Void> {
        return callHooks(postdeleteHooks, on: instance, context: context)
    }
    
    /// Calls the given `hooks` on the `instance`
    private static func callHooks<M: Model>(_ hooks: [WrappedHook], on instance: M, context: Context) -> EventLoopFuture<Void> {
        var futures = [EventLoopFuture<Void>]()
        
        for hook in hooks {
            do {
                try futures.append(hook.hook(instance, context))
            } catch {
                return context.eventLoop.newFailedFuture(error: error)
            }
        }
        
        return EventLoopFuture<Void>.andAll(futures, eventLoop: context.eventLoop)
    }
    
    internal static func hasDeleteHooks<M: Model>(forType type: M.Type) -> Bool {
        let hooks = predeleteHooks + postdeleteHooks
        return hooks.filter { $0.typeCheck(M.self) }.count > 0
    }
}
