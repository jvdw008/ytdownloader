unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls, Process, Windows, ShellAPI;

type

  TDownloadThread = class(TThread)
  private
    FCommand: String;
    procedure UpdateProgress; // Runs in the main thread
    procedure FinalizeProgress;
  protected
    procedure Execute; override;
  public
    constructor Create(const Command: String);
  end;

  { TForm1 }

  TForm1 = class(TForm)
    audioOnlyChkBox: TCheckBox;
    quitBtn: TButton;
    checkboxShowLog: TCheckBox;
    videoFormatLabel: TLabel;
    videoFormat: TListBox;
    resetBtn: TButton;
    downloadBtn: TButton;
    audioFormat: TListBox;
    fullCommand: TEdit;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    savePath: TEdit;
    savePathLbl: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    ytURL: TEdit;
    txtURL: TStaticText;
    procedure audioOnlyChkBoxChange(Sender: TObject);
    procedure quitBtnClick(Sender: TObject);
    procedure checkboxShowLogChange(Sender: TObject);
    procedure downloadBtnClick(Sender: TObject);
    procedure resetBtnClick(Sender: TObject);
    procedure savePathChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

const
  AppVersion = '0.0.2'; // Version

var
  Form1: TForm1;
  CurrentDateTime: TDateTime;
  audioOnly: Boolean;
  audioFormatSelected: String; // Default to mp3 - Requires FFMPEG itherwise defaults to opus
  urlPath: String;
  commandPath: String;
  commandLineExe: String;
  ffmpegPath: String;

implementation

{$R *.lfm}

{ TDownloadThread }

constructor TDownloadThread.Create(const Command: String);
begin
  FreeOnTerminate := True; // Automatically free memory when done
  FCommand := Command;
  inherited Create(False); // Start the thread immediately
end;

procedure TDownloadThread.UpdateProgress;
begin
  Form1.progressBar1.Position := Form1.progressBar1.Position + 1;
  if Form1.progressBar1.Position >= 100 then
     Form1.progressBar1.Position := 0;
end;

procedure TDownloadThread.FinalizeProgress;
begin
  Form1.ProgressBar1.Position := 100;
  // Enable this button last
  Form1.downloadBtn.Enabled := true;
  // Tell user we're done
  MessageDlg('Download for link ' + Form1.ytURL.Text + ' complete!', mtInformation, [mbOK], 0);
  // Open the folder after the process is complete
  ShellExecute(0, 'open', PChar(Form1.savePath.Text), nil, nil, SW_SHOWNORMAL);
end;

procedure TDownloadThread.Execute;
var
  AProcess: TProcess;
  OutputStream: TStringStream;
  OutputString: String;
  BytesRead: Integer;
  Buffer: array[0..2047] of Char;
  i: Integer;
  CommandParts: TStringList;
begin
  AProcess := TProcess.Create(nil);
  OutputStream := TStringStream.Create('');
  CommandParts := TStringList.Create;
  try
    // Split FCommand into separate parameters
    CommandParts.Delimiter := ' ';
    CommandParts.QuoteChar := '"';
    CommandParts.DelimitedText := FCommand;

    AProcess.Executable := commandLineExe;
    AProcess.Options := [poUsePipes, poNoConsole];

    // Add parameters correctly
    for i := 0 to CommandParts.Count - 1 do
      AProcess.Parameters.Add(CommandParts[i]);

    Form1.fullCommand.Text := StringReplace(commandLineExe + ' ' + CommandParts.Text , '\', '/', [rfReplaceAll]);
    AProcess.Execute;

    while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do
    begin
      // Read available output from process
      BytesRead := AProcess.Output.Read(Buffer, SizeOf(Buffer) - 1);
      if BytesRead > 0 then
      begin
        Buffer[BytesRead] := #0;
        OutputString := OutputString + Buffer;
        Synchronize(@UpdateProgress);
      end;

      Sleep(300); // Prevent CPU overuse
    end;

    Synchronize(@FinalizeProgress);

  finally
    AProcess.Free;
    OutputStream.Free;
    CommandParts.Free;
  end;
end;

{ TForm1 }

// This gets the YT link and checks if you want the audio only too, then runs the commandline exe
procedure TForm1.downloadBtnClick(Sender: TObject);
var
  CommandOptions: TStringList;
begin

  if ytURL.Text <> '' then
  begin

    // Disable this button first
    downloadBtn.Enabled := false;

    // Reset progress bar
    progressBar1.Position := 0;

    // Construct command options correctly
    CommandOptions := TStringList.Create;
    try
      // YT URL
      CommandOptions.Add(ytURL.Text);

      // Audio file extension
      CommandOptions.Add('-S ');
      CommandOptions.Add('ext ');

      if audioOnlyChkBox.Checked then
      begin
        CommandOptions.Add('-x ');
        CommandOptions.Add('--audio-format');
        if audioFormat.ItemIndex >= 0 then
          CommandOptions.Add(audioFormat.Items[audioFormat.ItemIndex])
        else
          CommandOptions.Add('mp3 ');
      end;

      // Set the video resolution
      if videoFormat.Enabled then
      begin
        CommandOptions.Add('-S ');
        if videoFormat.ItemIndex >= 0 then
          CommandOptions.Add('res:' + videoFormat.Items[videoFormat.ItemIndex] + ' ')
        else
          CommandOptions.Add('res:720 ');
      end;

      // Where FFMPEG is located
      CommandOptions.Add('--ffmpeg-location ');
      CommandOptions.Add(ffmpegPath);

      // Where to save your file
      CommandOptions.Add('-P ');
      CommandOptions.Add(savePath.Text);

      // Start the download in a separate thread
      TDownloadThread.Create(CommandOptions.Text);
    finally
      CommandOptions.Free;
    end;
  end;
end;

procedure TForm1.resetBtnClick(Sender: TObject);
begin
  // Default values
  ytURL.Text := '';
  fullCommand.Text := '';
  audioOnlyChkBox.Checked := false;
  progressBar1.Position := 0;
end;

procedure TForm1.audioOnlyChkBoxChange(Sender: TObject);
begin
  if audioOnlyChkBox.Checked then
  begin
    audioFormat.Enabled := true;
    videoFormat.Enabled := false
  end
  else
  begin
    audioFormat.Enabled := false;
    videoFormat.Enabled := true;
  end;
end;

procedure TForm1.quitBtnClick(Sender: TObject);
begin
   Application.Terminate;
end;


procedure TForm1.checkboxShowLogChange(Sender: TObject);
begin
  if checkboxShowLog.Checked then
    fullCommand.Visible := true
  else
    fullCommand.Visible := false;
end;

procedure TForm1.savePathChange(Sender: TObject);
begin
  // Set exe path
  commandPath := ExtractFilePath(ParamStr(0));
  commandLineExe := commandPath + 'yt-dlp.exe';
  ffmpegPath := commandPath;

  if SelectDirectoryDialog1.Execute then
    // Set save path
    savePath.Text := SelectDirectoryDialog1.FileName + PathDelim;

    // Enable download button if not empty
    if savePath.Text <> '' then
       downloadBtn.Enabled := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Disable resizing of the form by setting the min/max width/height to current width/height
  Self.Constraints.MinWidth := Self.Width;
  Self.Constraints.MinHeight := Self.Height;
  Self.Constraints.MaxWidth := Self.Width;
  Self.Constraints.MaxHeight := Self.Height;

  Self.Caption := 'YT Downloader - v' + AppVersion;
end;


end.

