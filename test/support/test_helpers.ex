defmodule Instructor.TestHelpers do
  import Mox

  def mock_openai_response(result) do
    InstructorTest.MockOpenAI
    |> expect(:chat_completion, fn _params ->
      {:ok,
       %{
         id: "chatcmpl-8e9AVo9NHfvBG5cdtAEiJMm7q4Htz",
         usage: %{
           "completion_tokens" => 23,
           "prompt_tokens" => 136,
           "total_tokens" => 159
         },
         choices: [
           %{
             "finish_reason" => "stop",
             "index" => 0,
             "logprobs" => nil,
             "message" => %{
               "content" => nil,
               "role" => "assistant",
               "tool_calls" => [
                 %{
                   "function" => %{
                     "arguments" => Jason.encode!(result),
                     "name" => "schema"
                   },
                   "id" => "call_DT9fBvVCHWGSf9IeFZnlarIY",
                   "type" => "function"
                 }
               ]
             }
           }
         ],
         model: "gpt-3.5-turbo-0613",
         object: "chat.completion",
         created: 1_704_579_055,
         system_fingerprint: nil
       }}
    end)
  end

  def mock_openai_response_stream(result) do
    chunks =
      Jason.encode!(%{value: result})
      |> String.graphemes()
      |> Enum.chunk_every(12)
      |> Enum.map(fn chunk ->
        chunk = Enum.join(chunk, "")

        %{
          "choices" => [
            %{
              "delta" => %{"tool_calls" => [%{"function" => %{"arguments" => chunk}}]},
              "finish_reason" => nil,
              "index" => 0,
              "logprobs" => nil
            }
          ],
          "created" => 1_704_666_072,
          "id" => "chatcmpl-8eVo0dIB83q0IzSvrZeO4tM1CO9y8",
          "model" => "gpt-3.5-turbo-0613",
          "object" => "chat.completion.chunk",
          "system_fingerprint" => nil
        }
      end)

    chunks =
      chunks ++
        [
          %{
            "choices" => [
              %{"delta" => %{}, "finish_reason" => "stop", "index" => 0, "logprobs" => nil}
            ],
            "created" => 1_704_666_072,
            "id" => "chatcmpl-8eVo0dIB83q0IzSvrZeO4tM1CO9y8",
            "model" => "gpt-3.5-turbo-0613",
            "object" => "chat.completion.chunk",
            "system_fingerprint" => nil
          }
        ]

    InstructorTest.MockOpenAI
    |> expect(:chat_completion, fn _params ->
      chunks
    end)
  end

  def is_stream?(variable) do
    case variable do
      %Stream{} ->
        true

      _ when is_function(variable, 0) or is_function(variable, 1) or is_function(variable, 2) ->
        true

      _ ->
        false
    end
  end
end
