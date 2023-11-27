-module(nums).
-export([main_p/2, zero_p/1, even_p/1, odd_p/0, main/1]).

main_p(0, ZeroPID) ->
  exit(ZeroPID);
main_p(N, ZeroPID) ->
  NumToPrint = N rem 10,
  ZeroPID ! {NumToPrint, self()},
  receive
    next -> main_p(N div 10, ZeroPID);
    _->main_p(0, ZeroPID)
  end.

zero_p(EvenPID) ->
  receive
    {Digit, MainPID} when is_pid(EvenPID) ->
      if
        Digit == 0 ->
          io:format("~w ", [Digit]),
          io:format("ZERO Process worked ~n"),
          MainPID ! next,
          zero_p(EvenPID);
        Digit /= 0 ->
          EvenPID ! {Digit, MainPID},
          zero_p(EvenPID)
      end
  end.

even_p(OddPID) ->
  receive
    {Digit, MainPID} when is_pid(OddPID) ->
      if Digit rem 2 == 0 ->
          io:format("~w ", [Digit]),
          io:format("EVEN Process worked ~n"),
          MainPID ! next,
          even_p(OddPID);
        Digit rem 2 /= 0 ->
          OddPID ! {Digit, MainPID},
          even_p(OddPID)
      end
  end.

odd_p() ->
  receive
    {Digit, MainPID} when is_pid(MainPID) ->
      io:format("~w ", [Digit]),
      io:format("ODD Process worked ~n"),
      MainPID ! next,
      odd_p()
  end.

main(N) ->
  PID_ODD = spawn(nums, odd_p, []),
  PID_EVEN = spawn(nums, even_p, [PID_ODD]),
  PID_ZERO = spawn(nums, zero_p, [PID_EVEN]),
  spawn(nums, main_p, [N, PID_ZERO]),
  timer:sleep(100).