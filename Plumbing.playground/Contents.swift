import Plumbing
import PlumbingHttp

//(Input) -> Output
//(Request)
//-> Check Headers
//-> Authenticação
//-> Decode Body
//-> Bate no Banco
//-> Response
//}

typealias Effect<Input, Success, Failure: Error> = (Input) async -> Result<Success, Failure>
typealias Effect<Input, Success, Failure: Error> = (Input) -> Task<Success, Failure>

func isAuthenticated(_ req: Request) -> Bool {
  return true
}

func recordCreateEvent() -> Void {

}

struct TodoItemInput: Decodable {
  let title: String
}

func addItemToTodolist(_ req: Request) -> AsyncResult<Response, Response> {
  AsyncResult<Request, Response>.success(req)
    .ensure(isAuthenticated, orFail: const(Response(status: .unauthorized)))
    .ensure({ req.method != .get }, orFail: const(Response(status: .notFound)))
    .decodeBody(as: TodoItemInput.self, orFail: const(Response(status: .badRequest)))
    .fireAndForget(recordCreateEvent)
}

let p = AsyncResult<Int, any Error>.success(1)
  .middleware(run: {
    print("ASDSADSA")
    return .success($0 + 1)
  })
  .middleware(
    run: { .success($0 + 1) },
    if: { $0 % 2 != 0 }
  )

print("A")

Task {
  let res = await p.run()
}
