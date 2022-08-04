open Jest
open Expect
open LoggerFns
let path1 = "/Users/mike/tmp/logs/org.nomadiclabs.umamiMobile 2022-08-03--16-41-50-110.log"
let path2 = "/Users/mike/tmp/logs/org.nomadiclabs.umamiMobile 2022-08-03--16-41-50-110.log"

describe("log parsing functions", () => {
  test("parseLogContent returns the right value", () => {
    let logFile = "2022-08-03T16:41:45.002Z [INFO] info message
2022-08-03T16:49:45.002Z [DEBUG] debug message
2022-09-03T16:41:45.002Z [WARN] warn message
2022-09-03T16:41:45.002Z [ERROR] error message
"

    let parsedLogs = parseLogContent(logFile)

    expect(parsedLogs)->toEqual([
      {date: "2022-08-03T16:41:45.002Z", message: "info message", level: Info},
      {date: "2022-08-03T16:49:45.002Z", message: "debug message", level: Debug},
      {date: "2022-09-03T16:41:45.002Z", message: "warn message", level: Warn},
      {date: "2022-09-03T16:41:45.002Z", message: "error message", level: Error_},
    ])
  })

  test("parseLogs returns the right value", () => {
    let input: array<raw> = [
      {
        content: "2022-08-03T16:41:50.109Z [INFO] hello
2022-08-03T16:44:40.109Z [ERROR] world
",
        path: path1,
      },
      {
        content: "
2022-09-03T16:41:45.002Z [WARN] how are you
",
        path: path2,
      },
    ]

    expect(parseLogs(input))->toEqual([
      (
        path1,
        [
          {date: "2022-08-03T16:41:50.109Z", message: "hello", level: Info},
          {date: "2022-08-03T16:44:40.109Z", message: "world", level: Error_},
        ],
      ),
      (path2, [{date: "2022-09-03T16:41:45.002Z", message: "how are you", level: Warn}]),
    ])
  })
})
