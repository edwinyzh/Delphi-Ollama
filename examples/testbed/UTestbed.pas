{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                           :%@@@+              =%@@%-
                          -@@*=@@#            +@@++@@+
                          %@%  =@@=          :@@+  *@@.
                         :@@=   @@%=*%@@@@%*=*@@.  -@@=
                         :@@=   %@@@%*=--=+%@@@@   :@@+
                         .@@#+**@@#:        .*@@#*+*@@-
                        .+@@@%###+            -###%@@@*.
                       -@@%=                        -#@@=
                      -@@*                            =@@*
                      @@#                              *@@:
                     .@@=    =#*.  :+#%@@%#*-  .*#+    -@@=
                      @@#    %@@--%%+:.   :=%@=:@@@:   +@@:
                      -@@*    . :@#   -##=   *@= .    =@@*
                       #@@+     -@*    *#    =@+     -@@%
                      -@@+       +@#-.    .:*@#       -@@+
                      #@@         .=*%%%%%%#=:         #@@
                      @@#                              +@@.
                      #@@                              #@@
                      -@@+                            -@@+
                       +@@#                          =@@*
                       #@@:                           %@%
                      :@@+                            :@@=
                      =@@:                             @@#
                      -@@-                            .@@*
     ___        _        _     _        ___   _  _
    |   \  ___ | | _ __ | |_  (_) ___  / _ \ | || | __ _  _ __   __ _™
    | |) |/ -_)| || '_ \| ' \ | ||___|| (_) || || |/ _` || '  \ / _` |
    |___/ \___||_|| .__/|_||_||_|      \___/ |_||_|\__,_||_|_|_|\__,_|
                  |_|       Ollama API in Delphi

Copyright © 2024-present tinyBigGAMES™ LLC
All Rights Reserved.

Website: https://tinybiggames.com
Email  : support@tinybiggames.com
License: BSD 3-Clause License

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

unit UTestbed;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  Ollama.Utils,
  Ollama;

procedure RunTests();

implementation

procedure Test01();
var
  LOllama: TOllama;
  LUsage: TOllama.Usage;
begin
  // create Ollama object
  LOllama := TOllama.Create();
  try
    // set model to use
    LOllama.AddModel('dolphin-mistral', 'text', 1024*2);

    // generate response
    if LOllama.Generate('text', 'hello') then
      begin
        // teletype response
        Console.Teletype(LOllama.GetResponse());

        // get usage
        LOllama.GetUsage(LUsage);

        // display usage info
        Console.PrintLn();
        Console.PrintLn('Token count: %d, Tokens/sec: %3.2f, Duration: %s',
          [LUsage.TokenCount, LUsage.TokensPerSecond,
          Utils.FormatSeconds(LUsage.TotalDuration)], Console.BRIGHTYELLOW);
      end
    else
      begin
        // display error
        Console.PrintLn(LOllama.GetResponse(), Console.RED);
      end;
  finally
    // free Ollama object
    LOllama.Free();
  end;
end;

procedure Test02();
const
  CPrompt =
  '''
  who are you?
  ''';
var
  LOllama: TOllama;
  LUsage: TOllama.Usage;
  LSuccess: Boolean;
  LTimer: TTimer;
  LStartTime: TDateTime;
  LDuration: Double;

  procedure Animate();
  const
    CAnimation = '|/-\';
    {$J+}
    LFrame: Integer = 1;
    {$J-}
  begin
    if LFrame > Length(CAnimation) then
      LFrame := 1
    else
    if LFrame < 1 then
      LFrame := Length(CAnimation);
    if ASync.Busy('ollama') then
    begin
      LDuration := Utils.TimeDifference(Now, LStartTime);
      If LDuration < 60 then
        Console.Print(Console.CR+'%s %3.1fs', [CAnimation[LFrame], LDuration],
          Console.MAGENTA)
      else
        Console.Print(Console.CR+'%s %3.1fm', [CAnimation[LFrame], LDuration],
          Console.MAGENTA);
    end;
    if LTimer.Check then
      Inc(LFrame);
  end;

begin
  // init timer & speech
  LTimer.InitFPS(18);
  Speech.SetRate(0.55);

  // create ollama object
  LOllama := TOllama.Create();
  try
    // set model to use
    LOllama.AddModel('dolphin-mistral', 'text', 1024*2);
    //LOllama.AddModel('qwen:7b', 'text', 1024*2);

    // display the prompt
    Console.PrintLn(CPrompt, Console.DARKGREEN);

    // start async task
    LSuccess := False;
    Async.Run('ollama',
      // background task
      procedure
      begin
        // generate a response
        LSuccess := LOllama.Generate('text', CPrompt);
      end,
      // forground task
      procedure
      begin
        // clean up animation status
        Console.SetCursorVisible(True);
        Console.ClearLine(Console.WHITE);
        Console.Print(Console.CR);

        // show respose
        if LSuccess then
          begin
            // speak response
            Speech.Say(LOllama.GetResponse(), True);

            // teletype response
            Console.Teletype(LOllama.GetResponse());

            // get and show usage
            LOllama.GetUsage(LUsage);
            Console.PrintLn();
            Console.PrintLn(
              'Tokens :: Total: %d, Speed: %3.2f T/S, Duration: %3.2f secs',
              [LUsage.TokenCount, LUsage.TokensPerSecond,
              LUsage.TotalDuration], Console.BRIGHTYELLOW);
          end
        else
          begin
            // display error response
            Console.Print(LOllama.GetResponse(), Console.RED);
          end;
      end
    );
    // turn off cursor
    Console.SetCursorVisible(False);

    // show animation status
    LStartTime := Now;
    while ASync.Busy('ollama') do
    begin
      // process messages
      Utils.ProcessMessages();

      // process async
      Async.Process();

      // update animation
      Animate();
    end;
  finally
    // free ollama object
    LOllama.Free();
  end;
end;

procedure RunTests();
begin
  //Test01();
  Test02();
  Console.Pause();
end;

end.
