import NIO

public enum MeowHooks {
    public typealias Hook<M> = (M, Context) throws -> EventLoopFuture<Void>
    
    private static var presaveHooks = [Any]()
    private static var postsaveHooks = [Any]()
    private static var predeleteHooks = [Any]()
    private static var postdeleteHooks = [Any]()
    
    /// Registers a new presave hook on the given model.
    /// Presave hooks are called before every save operation.
    ///
    /// When a presave hook throws, or when the future returned from a presave hook fails, the save
    /// operation is cancelled and the error is passed through to the caller of the `Context.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPresaveHook<M: Model>(_ handler: @escaping Hook<M>) {
        presaveHooks.append(handler)
    }
    
    /// Registers a new postsave hook on the given model.
    /// Postsave hooks are called after every save operation.
    ///
    /// When a postsave hook throws, or when the future returned from a postsave hook fails, the error is passed through to the caller of the `Context.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPostsaveHook<M: Model>(_ handler: @escaping Hook<M>) {
        presaveHooks.append(handler)
    }
    
    /// Registers a new predelete hook on the given model.
    /// Presave hooks are called before delete save operation.
    ///
    /// When a predelete hook throws, or when the future returned from a predelete hook fails, the delete
    /// operation is cancelled and the error is passed through to the caller of the `Context.delete` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPredeleteHook<M: Model>(_ handler: @escaping Hook<M>) {
        predeleteHooks.append(handler)
    }
    
    /// Registers a new postdelete hook on the given model.
    /// Presave hooks are called before delete save operation.
    ///
    /// When a postdelete hook throws, or when the future returned from a postsave hook fails, the error is passed through to the caller of the `Context.save` method.
    ///
    /// - warning: Registering hooks is NOT thread safe. Only register hooks in your application setup.
    public static func registerPostdeleteHook<M: Model>(_ handler: @escaping Hook<M>) {
        postdeleteHooks.append(handler)
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
    
    internal static func hasDeleteHooks<M: Model>(forType type: M.Type) -> Bool {
        let hooks = predeleteHooks + postdeleteHooks
        return hooks.compactMap { $0 as? Hook<M> }.count > 0
    }
}
