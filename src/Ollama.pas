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

unit Ollama;

{$I Ollama.Defines.inc}

interface

uses
  System.Generics.Collections,
  System.Classes,
  Ollama.Utils;

type
  { TOllama }
  TOllama = class(TBaseObject)
  public type
    Usage = record
      TotalDuration: Single;
      TokenCount: Cardinal;
      TokensPerSecond: Single;
    end;
  protected type
    TModel = record
      Name: string;
      MaxTokens: UInt64;
    end;
    TModels = TDictionary<string, TModel>;
  protected
    FBaseUrl: string;
    FTemperature: Single;
    FSystem: string;
    FContext: string;
    FModels: TModels;
    FUsage: TOllama.Usage;
    FSeed: Cardinal;
    FResponse: string;
    FJsonMode: Boolean;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure SetBaseUrl(const ABaseUrl: string);
    function  GetBaseUrl(): string;
    procedure AddModel(const AName, AReferenceName: string; const AMaxTokens: UInt64);
    procedure SetTemperature(const ATemperature: Single);
    procedure SetSystem(const ASystem: string);
    function  GetSystem(): string;
    procedure SetSystemFromFile(const AFilename: string);
    procedure SetContext(const AContext: string);
    function  GetContext(): string;
    procedure SetSeed(const ASeed: Cardinal);
    function  GetSeed(): Cardinal;
    procedure SetJsonMode(const AJsonMode: Boolean);
    function  GetJsonMode(): Boolean;
    procedure GetUsage(var AUsage: TOllama.Usage);
    function  Generate(const AModel: string; const APrompt: string): Boolean;
    function  GetResponse(): string;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  //System.DateUtils,
  System.Net.HttpClient;

{ TOllama }
constructor TOllama.Create();
begin
  inherited;
  FModels := TModels.Create();
  SetBaseUrl('http://localhost:11434');
  SetTemperature(0);
  SetSystem('');
  SetContext('');
  SetSeed(MaxInt);
  SetJsonMode(False);
  SetSystem('You are Delphi-Ollama, a simple and easy to use library for interacting with the Ollama API in Delphi.');
end;

destructor TOllama.Destroy();
begin
  FModels.Free();
  inherited;
end;

procedure TOllama.SetBaseUrl(const ABaseUrl: string);
begin
  FBaseUrl := ABaseUrl;
end;

function  TOllama.GetBaseUrl(): string;
begin
  Result := FBaseUrl;
end;

procedure TOllama.AddModel(const AName, AReferenceName: string; const AMaxTokens: UInt64);
var
  LModel: TModel;
begin
  LModel.Name := AName;
  LModel.MaxTokens := AMaxTokens;
  FMOdels.AddOrSetValue(AReferenceName, LModel);
end;

procedure TOllama.SetTemperature(const ATemperature: Single);
begin
  FTemperature := ATemperature;
end;

procedure TOllama.SetSystem(const ASystem: string);
begin
  FSystem := ASystem;
end;

procedure TOllama.SetSystemFromFile(const AFilename: string);
begin
  if not TFile.Exists(AFilename) then Exit;
  FSystem := TFile.ReadAllText(AFilename);
end;

function  TOllama.GetSystem(): string;
begin
  Result := FSystem;
end;

procedure TOllama.SetContext(const AContext: string);
begin
  FContext := AContext;
end;

function  TOllama.GetContext(): string;
begin
  Result := FContext;
end;

procedure TOllama.SetSeed(const ASeed: Cardinal);
begin
  FSeed := ASeed;
end;

function  TOllama.GetSeed(): Cardinal;
begin
  Result := FSeed;
end;

procedure TOllama.SetJsonMode(const AJsonMode: Boolean);
begin
  FJsonMode := AJsonMode;
end;

function  TOllama.GetJsonMode(): Boolean;
begin
  Result := FJsonMode;
end;

procedure TOllama.GetUsage(var AUsage: TOllama.Usage);
begin
  AUsage := FUsage;
end;

function TOllama.GetResponse(): string;
begin
  Result := FResponse;
end;

function TOllama.Generate(const AModel: string; const APrompt: string): Boolean;
var
  LHttpClient: THTTPClient;
  LJson: TJsonObject;
  LData: string;
  LPostDataStream: TStringStream;
  LResponse: IHTTPResponse;
  LUrl: string;
  LTotalDuration: Int64;
  LTokenCount: Cardinal;
  LTokensPerSecond: Double;
  LModel: TModel;
  LDone: Boolean;
begin
  Result := False;
  LDone := False;
  FResponse := '';
  FUsage.TotalDuration := 0;
  FUsage.TokenCount := 0;
  FUsage.TokensPerSecond := 0;


  if not FModels.TryGetValue(AModel, LModel) then
  begin
    FResponse := Format('Refrence model "%s" not found.', [AModel]);
    Exit;
  end;

  LHttpClient := THTTPClient.Create();
  try
    LHttpClient.CustomHeaders['Content-Type'] := 'application/json';

    LJson := TJsonObject.Create();
    try
      LJson.S['model'] := LModel.Name;
      LJson.S['prompt'] := APrompt;
      LJson.B['stream'] := False;
      LJson.S['system'] := FSystem;
      if FJsonMode then
        LJson.S['format'] := 'json';

      with LJson.AddObject('options') do
      begin
        I['seed'] := FSeed;
        F['temperature'] := FTemperature;
        I['num_ctx'] := LModel.MaxTokens;
      end;
      LData := LJson.ToJSON();
      //writeln(LData);
    finally
      LJson.Free();
    end;

    LPostDataStream := TStringStream.Create(LData, TEncoding.UTF8);
    try
      LPostDataStream.Position := 0;
      try
        LUrl := Utils.CombineURL(FBaseUrl, 'api/generate');
        LResponse := LHttpClient.Post(LUrl, LPostDataStream);
      except
        on E: Exception do
        begin
          FResponse := E.Message;
          Exit;
        end;
      end;
      LData := LResponse.ContentAsString;
      //writeln(LData);
    finally
      LPostDataStream.Free;
    end;

    LJson := TJsonObject.Parse(LData) as TJsonObject;
    try
      if LResponse.StatusCode = 200 then
        begin
          if LJson.Contains('response') then
            FResponse := LJson.S['response'];

          if LJson.Contains('context') then
            FContext := LJson.A['context'].ToString();

          if LJson.Contains('done') then
            LDone := LJson.B['done'];

          if LDone then
          begin
            LTotalDuration := LJson.GetValue('total_duration').ToString.ToInt64;
            LTokenCount := LJson.GetValue('eval_count').ToString.ToInt64;
            LTokensPerSecond := LTokenCount / (LTotalDuration / 1e9); // convert nanoseconds to seconds

            FUsage.TotalDuration := LTotalDuration / 1e9;
            FUsage.TokenCount := LTokenCount;
            FUsage.TokensPerSecond := LTokensPerSecond;
          end;

          Result := True;
        end
      else
        begin
          if LJson.Contains('error') then
            FResponse := 'Error: ' + LJson.S['error']
          else
            FResponse := 'Error: ' + LData;
        end;
    finally
      LJson.Free();
    end;

  finally
    LHttpClient.Free();
  end;
end;

end.
