```  
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
```

[![Chat on Discord](https://img.shields.io/discord/754884471324672040.svg?logo=discord)](https://discord.gg/tPWjMwK) [![Twitter Follow](https://img.shields.io/twitter/follow/tinyBigGAMES?style=social)](https://twitter.com/tinyBigGAMES)

# Delphi-Ollama
A simple and easy to use library for interacting with the Ollama API in Delphi.

First, install and setup <a href="https://github.com/ollama/ollama" target="_blank">Ollama</a>.

Simple example:
```Delphi  
uses
  System.SysUtils,
  Ollama.Utils,
  Ollama;
  
var
  LOllama: TOllama;
  LUsage: TOllama.Usage;
  
begin
  // create Ollama object
  LOllama := TOllama.Create();
  try
    // add a model to use
    LOllama.AddModel('dolphin-mistral', 'text', 1024*2);

    // generate response
    if LOllama.Generate('text', 'hello') then
      begin
        // print response
        WriteLn(LOllama.GetResponse());

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
end.
```

An example using using a background thread and speech:
```Delphi  
uses
  System.SysUtils,
  Ollama.Utils,
  Ollama;
  
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
end.
```

### Media


https://github.com/tinyBigGAMES/Delphi-Ollama/assets/69952438/553b212f-cda8-403c-9d73-7d867d63aacc


### Support
Our development motto: 
- We will not release products that are buggy, incomplete, adding new features over not fixing underlying issues.
- We will strive to fix issues found with our products in a timely manner.
- We will maintain an attitude of quality over quantity for our products.
- We will establish a great rapport with users/customers, with communication, transparency and respect, always encouragingng feedback to help shape the direction of our products.
- We will be decent, fair, remain humble and committed to the craft.

### Links
- <a href="https://github.com/tinyBigGAMES/Delphi-Ollama/issues" target="_blank">Issues</a>
- <a href="https://github.com/tinyBigGAMES/Delphi-Ollama/discussions" target="_blank">Discussions</a>
- <a href="https://discord.gg/tPWjMwK" target="_blank">Discord</a>
- <a href="https://youtube.com/tinyBigGAMES" target="_blank">YouTube</a>
- <a href="https://twitter.com/tinyBigGAMES" target="_blank">X (Twitter)</a>
- <a href="https://ollama.com/" target="_blank">Ollama</a>
- <a href="https://learndelphi.org/" target="_blank">learndelphi.org</a>
- <a href="https://tinybiggames.com/" target="_blank">tinyBigGAMES</a>

<p align="center">
  <img src="media/techpartner-white.png" alt="Embarcadero Technical Partner Logo" width="200"/>
  <br>
  Proud to be an <strong>Embarcadero Technical Partner</strong>.
</p>
<sub>As an Embarcadero Technical Partner, I'm committed to providing high-quality Delphi components and tools that enhance developer productivity and harness the power of Embarcadero's developer tools.</sub>

