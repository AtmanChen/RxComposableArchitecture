import CasePaths
import Darwin
import RxSwift

/// This API has been soft-deprecated in favor of ``ReducerProtocol``.
/// Read <doc:MigratingToTheReducerProtocol> for more information.
///
/// A reducer describes how to evolve the current state of an application to the next state, given
/// an action, and describes what ``Effect``s should be executed later by the store, if any.
///
/// Reducers have 3 generics:
///
///   * `State`: A type that holds the current state of the application.
///   * `Action`: A type that holds all possible actions that cause the state of the application to
///     change.
///   * `Environment`: A type that holds all dependencies needed in order to produce ``Effect``s,
///     such as API clients, analytics clients, random number generators, etc.
///
/// > Important: The thread on which effects output is important. An effect's output is immediately
///   sent back into the store, and ``Store`` is not thread safe. This means all effects must
///   receive values on the same thread, **and** if the ``Store`` is being used to drive UI then all
///   output must be on the main thread. You can use the `Publisher` method `receive(on:)` for make
///   the effect output its values on the thread of your choice.
/// >
/// > This is only an issue if using the Combine interface of ``Effect`` as mentioned above. If you
///   you are only using Swift's concurrency tools and the `.task`, `.run` and `.fireAndForget`
///   functions on ``Effect``, then the threading is automatically handled for you.
@available(
    iOS,
    deprecated: 9999.0,
    message:
        """
    This API has been soft-deprecated in favor of 'ReducerProtocol'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
    """
)
public struct AnyReducer<State, Action, Environment> {
    private let reducer: (inout State, Action, Environment) -> Effect<Action>

    /// > This API has been soft-deprecated in favor of ``ReducerProtocol``.
    /// Read <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// Initializes a reducer from a simple reducer function signature.
    ///
    /// The reducer takes three arguments: state, action and environment. The state is `inout` so that
    /// you can make any changes to it directly inline. The reducer must return an effect, which
    /// typically would be constructed by using the dependencies inside the `environment` value. If
    /// no effect needs to be executed, a ``Effect/none`` effect can be returned.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct MyState { var count = 0, text = "" }
    /// enum MyAction { case buttonTapped, textChanged(String) }
    /// struct MyEnvironment { var analyticsClient: AnalyticsClient }
    ///
    /// let myReducer = AnyReducer<MyState, MyAction, MyEnvironment> { state, action, environment in
    ///   switch action {
    ///   case .buttonTapped:
    ///     state.count += 1
    ///     return environment.analyticsClient.track("Button Tapped")
    ///
    ///   case .textChanged(let text):
    ///     state.text = text
    ///     return .none
    ///   }
    /// }
    /// ```
    ///
    /// - Parameter reducer: A function signature that takes state, action and
    ///   environment.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
      This API has been soft-deprecated in favor of 'ReducerProtocol'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
      """
    )
    public init(_ reducer: @escaping (inout State, Action, Environment) -> Effect<Action>) {
        self.reducer = reducer
    }

    public static var empty: AnyReducer {
        Self { _, _, _ in .none }
    }

    /// This API has been soft-deprecated in favor of combining reducers in a ``ReducerBuilder``. Read
    /// <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// Combines many reducers into a single one by running each one on state in order, and merging
    /// all of the effects.
    ///
    /// It is important to note that the order of combining reducers matter. Combining `reducerA` with
    /// `reducerB` is not necessarily the same as combining `reducerB` with `reducerA`.
    ///
    /// This can become an issue when working with reducers that have overlapping domains. For
    /// example, if `reducerA` embeds the domain of `reducerB` and reacts to its actions or modifies
    /// its state, it can make a difference if `reducerA` chooses to modify `reducerB`'s state
    /// _before_ or _after_ `reducerB` runs.
    ///
    /// This is perhaps most easily seen when working with ``optional(file:fileID:line:)`` reducers,
    /// where the parent domain may listen to the child domain and `nil` out its state. If the parent
    /// reducer runs before the child reducer, then the child reducer will not be able to react to its
    /// own action.
    ///
    /// Similar can be said for a ``forEach(state:action:environment:file:fileID:line:)-2ypoa``
    /// reducer. If the parent domain modifies the child collection by moving, removing, or modifying
    /// an element before the `forEach` reducer runs, the `forEach` reducer may perform its action
    /// against the wrong element, an element that no longer exists, or an element in an unexpected
    /// state.
    ///
    /// Running a parent reducer before a child reducer can be considered an application logic
    /// error, and can produce assertion failures. So you should almost always combine reducers in
    /// order from child to parent domain.
    ///
    /// Here is an example of how you should combine an ``optional(file:fileID:line:)`` reducer with a
    /// parent domain:
    ///
    /// ```swift
    /// let parentReducer = AnyReducer<ParentState, ParentAction, ParentEnvironment>.combine(
    ///   // Combined before parent so that it can react to `.dismiss` while state is non-`nil`.
    ///   childReducer.optional().pullback(
    ///     state: \.child,
    ///     action: /ParentAction.child,
    ///     environment: { $0.child }
    ///   ),
    ///   // Combined after child so that it can `nil` out child state upon `.child(.dismiss)`.
    ///   AnyReducer { state, action, environment in
    ///     switch action
    ///     case .child(.dismiss):
    ///       state.child = nil
    ///       return .none
    ///     ...
    ///     }
    ///   },
    /// )
    /// ```
    ///
    /// - Parameter reducers: A list of reducers.
    /// - Returns: A single reducer.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
      This API has been soft-deprecated in favor of combining reducers in a 'ReducerBuilder'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
      """
    )
    public static func combine(_ reducers: Self...) -> Self {
        .combine(reducers)
    }

    /// This API has been soft-deprecated in favor of combining reducers in a ``ReducerBuilder``. Read
    /// <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// Combines many reducers into a single one by running each one on state in order, and merging
    /// all of the effects.
    ///
    /// This method is identical to ``AnyReducer/combine(_:)-94fzl`` except that it takes an array
    /// of reducers instead of a variadic list. See the documentation on
    /// ``AnyReducer/combine(_:)-94fzl`` for more information about what this method does.
    ///
    /// - Parameter reducers: An array of reducers.
    /// - Returns: A single reducer.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
          This API has been soft-deprecated in favor of combining reducers in a 'ReducerBuilder'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
          """
    )
    public static func combine(_ reducers: [Self]) -> Self {
        Self { state, action, environment in
            .merge(reducers.map { $0.reducer(&state, action, environment) })
        }
    }

    /// This API has been soft-deprecated in favor of ``Scope``. Read
    /// <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// Transforms a reducer that works on child state, action, and environment into one that works on
    /// parent state, action and environment. It accomplishes this by providing 3 transformations to
    /// the method:
    ///
    ///   * A writable key path that can get/set a piece of child state from the parent state.
    ///   * A case path that can extract/embed a child action into a parent action.
    ///   * A function that can transform the parent environment into a child environment.
    ///
    /// This operation is important for breaking down large reducers into small ones. When used with
    /// the ``combine(_:)-y8ee`` operator you can define many reducers that work on small pieces of
    /// domain, and then _pull them back_ and _combine_ them into one big reducer that works on a
    /// large domain.
    ///
    /// ```swift
    /// // Global domain that holds a child domain:
    /// struct AppState { var settings: SettingsState, /* rest of state */ }
    /// enum AppAction { case settings(SettingsAction), /* other actions */ }
    /// struct AppEnvironment { var settings: SettingsEnvironment, /* rest of dependencies */ }
    ///
    /// // A reducer that works on the child domain:
    /// let settingsReducer = AnyReducer<SettingsState, SettingsAction, SettingsEnvironment> { ... }
    ///
    /// // Pullback the settings reducer so that it works on all of the app domain:
    /// let appReducer = AnyReducer<AppState, AppAction, AppEnvironment>.combine(
    ///   settingsReducer.pullback(
    ///     state: \.settings,
    ///     action: /AppAction.settings,
    ///     environment: { $0.settings }
    ///   ),
    ///
    ///   /* other reducers */
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - toChildState: A key path that can get/set `State` inside `ParentState`.
    ///   - toChildAction: A case path that can extract/embed `Action` from `ParentAction`.
    ///   - toChildEnvironment: A function that transforms `ParentEnvironment` into `Environment`.
    /// - Returns: A reducer that works on `ParentState`, `ParentAction`, `ParentEnvironment`.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
        This API has been soft-deprecated in favor of 'Scope'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
        """
    )
    public func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
        state toLocalState: WritableKeyPath<GlobalState, State>,
        action toLocalAction: CasePath<GlobalAction, Action>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
    ) -> AnyReducer<GlobalState, GlobalAction, GlobalEnvironment> {
        .init { globalState, globalAction, globalEnvironment in
            guard let localAction = toLocalAction.extract(from: globalAction) else { return .none }
            return self.reducer(
                &globalState[keyPath: toLocalState],
                localAction,
                toLocalEnvironment(globalEnvironment)
            )
            .map(toLocalAction.embed)
        }
    }
    
    ///
    /// - Parameters:
    ///   - toLocalState: A key path that can get/set `State` inside `ParentState`.
    ///   - toLocalAction: A case path that can extract/embed `Action` from `ParentAction`.
    ///   - toLocalEnvironment: A function that transforms `ParentEnvironment` into `Environment`.
    ///   - assertOnInvalidAction: A flag indicate we run assertion for `invalid action` that `not match` with our current extract-ed/embed-ed `State` from `ParentState`.
    /// - Returns: A reducer that works on `ParentState`, `ParentAction`, `ParentEnvironment`.
    public func pullback<GlobalState, GlobalAction, GlobalEnvironment, StatePath, ActionPath>(
        state toLocalState: StatePath,
        action toLocalAction: ActionPath,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        assertOnInvalidAction: Bool = true,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> AnyReducer<GlobalState, GlobalAction, GlobalEnvironment>
    where
        StatePath: WritablePath, StatePath.Root == GlobalState, StatePath.Value == State,
        ActionPath: WritablePath, ActionPath.Root == GlobalAction, ActionPath.Value == Action
    {
        return .init { globalState, globalAction, globalEnvironment in
            guard let localAction = toLocalAction.extract(from: globalAction) else { return .none }
            
            guard var localState = toLocalState.extract(from: globalState) else {
                #if DEBUG
                    if assertOnInvalidAction {
                        runtimeWarn(
                          """
                          A reducer pulled back from "\(fileID):\(line)" received an action when child state was \
                          unavailable. …

                            Action:
                              \(debugCaseOutput(localAction))

                          This is generally considered an application logic error, and can happen for a few \
                          reasons:

                          • The reducer for a particular case of state was combined with or run from another \
                          reducer that set "\(typeName(GlobalState.self))" to another case before the reducer ran. \
                          Combine or run case-specific reducers before reducers that may set their state to \
                          another case. This ensures that case-specific reducers can handle their actions while \
                          their state is available.

                          • An in-flight effect emitted this action when state was unavailable. While it may be \
                          perfectly reasonable to ignore this action, you may want to cancel the associated \
                          effect before state is set to another case, especially if it is a long-living effect.

                          • This action was sent to the store while state was another case. Make sure that \
                          actions for this reducer can only be sent to a view store when state is non-"nil". \
                          In SwiftUI applications, use "SwitchStore".
                          """
                        )
                    }
                #endif

                return .none
            }
            
            let effect =
                self
                .reducer(&localState, localAction, toLocalEnvironment(globalEnvironment))
                .map { localAction -> GlobalAction in
                    var globalAction = globalAction
                    toLocalAction.set(into: &globalAction, localAction)
                    return globalAction
                }
            toLocalState.set(into: &globalState, localState)
            return effect
        }
    }

    /// This API has been soft-deprecated in favor of
    /// ``ReducerProtocol/ifLet(_:action:then:file:fileID:line:)``. Read
    /// <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// Transforms a reducer that works on non-optional state into one that works on optional state by
    /// only running the non-optional reducer when state is non-nil.
    ///
    /// Often used in tandem with ``pullback(state:action:environment:)`` to transform a reducer on a
    /// non-optional child domain into a reducer that can be combined with a reducer on a parent
    /// domain that contains some optional child domain:
    ///
    /// ```swift
    /// // Parent domain that holds an optional child domain:
    /// struct AppState { var modal: ModalState? }
    /// enum AppAction { case modal(ModalAction) }
    /// struct AppEnvironment { var mainQueue: AnySchedulerOf<DispatchQueue> }
    ///
    /// // A reducer that works on the non-optional child domain:
    /// let modalReducer = Reducer<ModalState, ModalAction, ModalEnvironment { ... }
    ///
    /// // Pullback the modal reducer so that it works on all of the app domain:
    /// let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    ///   modalReducer.optional().pullback(
    ///     state: \.modal,
    ///     action: /AppAction.modal,
    ///     environment: { ModalEnvironment(mainQueue: $0.mainQueue) }
    ///   ),
    ///   Reducer { state, action, environment in
    ///     ...
    ///   }
    /// )
    /// ```
    ///
    /// Take care when combining optional reducers into parent domains. An optional reducer cannot
    /// process actions in its domain when its state is `nil`. If a child action is sent to an
    /// optional reducer when child state is `nil`, it is generally considered a logic error. There
    /// are a few ways in which these errors can sneak into a code base:
    ///
    ///   * A parent reducer sets child state to `nil` when processing a child action and runs
    ///     _before_ the child reducer:
    ///
    ///     ```swift
    ///     let parentReducer = Reducer<ParentState, ParentAction, ParentEnvironment>.combine(
    ///       // When combining reducers, the parent reducer runs first
    ///       Reducer { state, action, environment in
    ///         switch action {
    ///         case .child(.didDisappear):
    ///           // And `nil`s out child state when processing a child action
    ///           state.child = nil
    ///           return .none
    ///         ...
    ///         }
    ///       },
    ///       // Before the child reducer runs
    ///       childReducer.optional().pullback(...)
    ///     )
    ///
    ///     let childReducer = Reducer<
    ///       ChildState, ChildAction, ChildEnvironment
    ///     > { state, action environment in
    ///       case .didDisappear:
    ///         // This action is never received here because child state is `nil` in the parent
    ///       ...
    ///     }
    ///     ```
    ///
    ///     To ensure that a child reducer can process any action that a parent may use to `nil` out
    ///     its state, combine it _before_ the parent:
    ///
    ///     ```swift
    ///     let parentReducer = Reducer<ParentState, ParentAction, ParentEnvironment>.combine(
    ///       // The child runs first
    ///       childReducer.optional().pullback(...),
    ///       // The parent runs after
    ///       Reducer { state, action, environment in
    ///         ...
    ///       }
    ///     )
    ///     ```
    ///
    ///   * A child effect feeds a child action back into the store when child state is `nil`:
    ///
    ///     ```swift
    ///     let childReducer = Reducer<
    ///       ChildState, ChildAction, ChildEnvironment
    ///     > { state, action environment in
    ///       switch action {
    ///       case .onAppear:
    ///         // An effect may want to feed its result back to the child domain in an action
    ///         return environment.apiClient
    ///           .request()
    ///           .map(ChildAction.response)
    ///
    ///       case let .response(response):
    ///         // But the child cannot process this action if its state is `nil` in the parent
    ///       ...
    ///       }
    ///     }
    ///     ```
    ///
    ///     It is perfectly reasonable to ignore the result of an effect when child state is `nil`,
    ///     for example one-off effects that you don't want to cancel. However, many long-living
    ///     effects _should_ be explicitly canceled when tearing down a child domain:
    ///
    ///     ```swift
    ///     let childReducer = Reducer<
    ///       ChildState, ChildAction, ChildEnvironment
    ///     > { state, action environment in
    ///       enum MotionID {}
    ///
    ///       switch action {
    ///       case .onAppear:
    ///         // Mark long-living effects that shouldn't outlive their domain cancellable
    ///         return environment.motionClient
    ///           .start()
    ///           .map(ChildAction.motion)
    ///           .cancellable(id: MotionID.self)
    ///
    ///       case .onDisappear:
    ///         // And explicitly cancel them when the domain is torn down
    ///         return .cancel(id: MotionID.self)
    ///       ...
    ///       }
    ///     }
    ///     ```
    ///
    ///   * A view store sends a child action when child state is `nil`:
    ///
    ///     ```swift
    ///     WithViewStore(self.parentStore) { parentViewStore in
    ///       // If child state is `nil`, it cannot process this action.
    ///       Button("Child Action") { parentViewStore.send(.child(.action)) }
    ///       ...
    ///     }
    ///     ```
    ///
    ///     Use ``Store/scope(state:action:)`` with ``IfLetStore`` or ``Store/ifLet(then:else:)`` to
    ///     ensure that views can only send child actions when the child domain is non-`nil`.
    ///
    ///     ```swift
    ///     IfLetStore(
    ///       self.parentStore.scope(state: { $0.child }, action: { .child($0) }
    ///     ) { childStore in
    ///       // This destination only appears when child state is non-`nil`
    ///       WithViewStore(childStore) { childViewStore in
    ///         // So this action can only be sent when child state is non-`nil`
    ///         Button("Child Action") { childViewStore.send(.action) }
    ///       }
    ///       ...
    ///     }
    ///     ```
    ///
    /// - See also: ``IfLetStore``, a SwiftUI helper for transforming a store on optional state into a
    ///   store on non-optional state.
    /// - See also: ``Store/ifLet(then:else:)``, a UIKit helper for doing imperative work with a store
    ///   on optional state.
    ///
    /// - Returns: A reducer that works on optional state.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
        This API has been soft-deprecated in favor of 'ReducerProtocol.ifLet'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
        """
    )
    public func optional(
        breakpointOnNil: Bool = true,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> AnyReducer<
        State?, Action, Environment
    > {
        .init { state, action, environment in
            guard state != nil else {
                #if DEBUG
                    if breakpointOnNil {
                        fputs(
                            """
                            ---
                            Warning: AnyReducer.optional@\(file):\(line)

                            "\(debugCaseOutput(action))" was received by an optional reducer when its state was \
                            "nil". This is generally considered an application logic error, and can happen for a \
                            few reasons:

                            * The optional reducer was combined with or run from another reducer that set \
                            "\(State.self)" to "nil" before the optional reducer ran. Combine or run optional \
                            reducers before reducers that can set their state to "nil". This ensures that \
                            optional reducers can handle their actions while their state is still non-"nil".

                            * An in-flight effect emitted this action while state was "nil". While it may be \
                            perfectly reasonable to ignore this action, you may want to cancel the associated \
                            effect before state is set to "nil", especially if it is a long-living effect.

                            * This action was sent to the store while state was "nil". Make sure that actions \
                            for this reducer can only be sent to a view store when state is non-"nil". In \
                            SwiftUI applications, use "IfLetStore".
                            ---

                            """,
                            stderr
                        )
                        raise(SIGTRAP)
                    }
                #endif
                return .none
            }
            return self.reducer(&state!, action, environment)
        }
    }

    /// This API has been soft-deprecated in favor of
    /// ``ReducerProtocol/forEach(_:action:_:file:fileID:line:)``. Read
    /// <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// A version of ``pullback(state:action:environment:)`` that transforms a reducer that works on
    /// an element into one that works on an identified array of elements.
    ///
    /// ```swift
    /// // Parent domain that holds a collection of child domains:
    /// struct AppState { var todos: IdentifiedArrayOf<Todo> }
    /// enum AppAction { case todo(id: Todo.ID, action: TodoAction) }
    /// struct AppEnvironment { var mainQueue: AnySchedulerOf<DispatchQueue> }
    ///
    /// // A reducer that works on an element's domain:
    /// let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { ... }
    ///
    /// // Pullback the todo reducer so that it works on all of the app domain:
    /// let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    ///   todoReducer.forEach(
    ///     state: \.todos,
    ///     action: /AppAction.todo(id:action:),
    ///     environment: { _ in TodoEnvironment() }
    ///   ),
    ///   Reducer { state, action, environment in
    ///     ...
    ///   }
    /// )
    /// ```
    ///
    /// Take care when combining `forEach` reducers into parent domains, as order matters. Always
    /// combine `forEach` reducers _before_ parent reducers that can modify the collection.
    ///
    /// - Parameters:
    ///   - toElementsState: A key path that can get/set a collection of `State` elements inside
    ///     `ParentState`.
    ///   - toElementAction: A case path that can extract/embed `(ID, Action)` from `ParentAction`.
    ///   - toElementEnvironment: A function that transforms `ParentEnvironment` into `Environment`.
    /// - Returns: A reducer that works on `ParentState`, `ParentAction`, `ParentEnvironment`.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
        This API has been soft-deprecated in favor of 'ReducerProtocol.forEach'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
        """
    )
    public func forEach<GlobalState, GlobalAction, GlobalEnvironment, Key>(
        state toLocalState: WritableKeyPath<GlobalState, [Key: State]>,
        action toLocalAction: CasePath<GlobalAction, (Key, Action)>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        breakpointOnNil: Bool = true,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> AnyReducer<GlobalState, GlobalAction, GlobalEnvironment> {
        .init { globalState, globalAction, globalEnvironment in
            guard let (key, localAction) = toLocalAction.extract(from: globalAction) else {
                return .none
            }
            if globalState[keyPath: toLocalState][key] == nil {
                #if DEBUG
                    if breakpointOnNil {
                        fputs(
                            """
                            ---
                            Warning: AnyReducer.forEach@\(file):\(line)

                            "\(debugCaseOutput(localAction))" was received by a "forEach" reducer at key \(key) \
                            when its state contained no element at this key. This is generally considered an \
                            application logic error, and can happen for a few reasons:

                            * This "forEach" reducer was combined with or run from another reducer that removed \
                            the element at this key when it handled this action. To fix this make sure that this \
                            "forEach" reducer is run before any other reducers that can move or remove elements \
                            from state. This ensures that "forEach" reducers can handle their actions for the \
                            element at the intended key.

                            * An in-flight effect emitted this action while state contained no element at this \
                            key. It may be perfectly reasonable to ignore this action, but you also may want to \
                            cancel the effect it originated from when removing a value from the dictionary, \
                            especially if it is a long-living effect.

                            * This action was sent to the store while its state contained no element at this \
                            key. To fix this make sure that actions for this reducer can only be sent to a view \
                            store when its state contains an element at this key.
                            ---

                            """,
                            stderr
                        )
                        raise(SIGTRAP)
                    }
                #endif
                return .none
            }
            return self.reducer(
                &globalState[keyPath: toLocalState][key]!,
                localAction,
                toLocalEnvironment(globalEnvironment)
            )
            .map { toLocalAction.embed((key, $0)) }
        }
    }

    /// A version of `pullback` that transforms a reducer that works on an element into one that works
    /// on an identified array of elements.
    ///
    ///     // Global domain that holds a collection of local domains:
    ///     struct AppState { var todos: IdentifiedArrayOf<Todo> }
    ///     enum AppAction { case todo(id: Todo.ID, action: TodoAction) }
    ///     struct AppEnvironment { var mainQueue: AnySchedulerOf<DispatchQueue> }
    ///
    ///     // A reducer that works on a local domain:
    ///     let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { ... }
    ///
    ///     // Pullback the local todo reducer so that it works on all of the app domain:
    ///     let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    ///       todoReducer.forEach(
    ///         state: \.todos,
    ///         action: /AppAction.todo(id:action:),
    ///         environment: { _ in TodoEnvironment() }
    ///       ),
    ///       Reducer { state, action, environment in
    ///         ...
    ///       }
    ///     )
    ///
    /// Take care when combining `forEach` reducers into parent domains, as order matters. Always
    /// combine `forEach` reducers _before_ parent reducers that can modify the collection.
    ///
    /// - Parameters:
    ///   - toLocalState: A key path that can get/set a collection of `State` elements inside
    ///     `GlobalState`.
    ///   - toLocalAction: A case path that can extract/embed `(Collection.Index, Action)` from
    ///     `GlobalAction`.
    ///   - toLocalEnvironment: A function that transforms `GlobalEnvironment` into `Environment`.
    ///   - breakpointOnNil: Raises `SIGTRAP` signal when an action is sent to the reducer but the
    ///     identified array does not contain an element with the action's identifier. This is
    ///     generally considered a logic error, as a child reducer cannot process a child action
    ///     for unavailable child state.
    /// - Returns: A reducer that works on `GlobalState`, `GlobalAction`, `GlobalEnvironment`.
    public func forEach<GlobalState, GlobalAction, GlobalEnvironment, ID>(
        state toLocalState: WritableKeyPath<GlobalState, IdentifiedArray<ID, State>>,
        action toLocalAction: CasePath<GlobalAction, (ID, Action)>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        breakpointOnNil: Bool = true,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> AnyReducer<GlobalState, GlobalAction, GlobalEnvironment> {
        .init { globalState, globalAction, globalEnvironment in
            guard let (id, localAction) = toLocalAction.extract(from: globalAction) else {
                return .none
            }
            if globalState[keyPath: toLocalState][id: id] == nil {
                #if DEBUG
                    if breakpointOnNil {
                        fputs(
                            """
                            ---
                            Warning: AnyReducer.forEach@\(file):\(line)

                            "\(debugCaseOutput(localAction))" was received by a "forEach" reducer at id \(id) \
                            when its state contained no element at this id. This is generally considered an \
                            application logic error, and can happen for a few reasons:

                            * This "forEach" reducer was combined with or run from another reducer that removed \
                            the element at this id when it handled this action. To fix this make sure that this \
                            "forEach" reducer is run before any other reducers that can move or remove elements \
                            from state. This ensures that "forEach" reducers can handle their actions for the \
                            element at the intended id.

                            * An in-flight effect emitted this action while state contained no element at this \
                            id. It may be perfectly reasonable to ignore this action, but you also may want to \
                            cancel the effect it originated from when removing an element from the identified \
                            array, especially if it is a long-living effect.

                            * This action was sent to the store while its state contained no element at this id. \
                            To fix this make sure that actions for this reducer can only be sent to a view store \
                            when its state contains an element at this id. In SwiftUI applications, use \
                            "ForEachStore".
                            ---

                            """,
                            stderr
                        )
                        raise(SIGTRAP)
                    }
                #endif
                return .none
            }
            return self.reducer(
                &globalState[keyPath: toLocalState][id: id]!,
                localAction,
                toLocalEnvironment(globalEnvironment)
            )
            .map { toLocalAction.embed((id, $0)) }
        }
    }

    public func combined(with other: Self) -> Self {
        .combine(self, other)
    }

    /// This API has been soft-deprecated in favor of ``ReducerProtocol/reduce(into:action:)-4nzr2``.
    /// Read <doc:MigratingToTheReducerProtocol> for more information.
    ///
    /// Runs the reducer.
    ///
    /// - Parameters:
    ///   - state: Mutable state.
    ///   - action: An action.
    ///   - environment: An environment.
    /// - Returns: An effect that can emit zero or more actions.
    @available(
        iOS,
        deprecated: 9999.0,
        message:
            """
        This API has been soft-deprecated in favor of 'ReducerProtocol.reduce(into:action:)'. Read the migration guide for more information: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol
        """
    )
    public func run(
        _ state: inout State,
        _ action: Action,
        _ environment: Environment
    ) -> Effect<Action> {
        #if DEBUG
            reducer(
                &state, action, Bootstrap.get(environment: type(of: environment)) ?? environment)
        #else
            reducer(&state, action, environment)
        #endif
    }
}
