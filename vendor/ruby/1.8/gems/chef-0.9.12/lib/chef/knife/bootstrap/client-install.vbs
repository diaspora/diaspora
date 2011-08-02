'
' Author:: Doug MacEachern <dougm@vmware.com>
' Copyright:: Copyright (c) 2010 VMware, Inc.
' License:: Apache License, Version 2.0
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
' 
'     http://www.apache.org/licenses/LICENSE-2.0
' 
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.
'
' download & install ruby && install chef client gems

Exe = "rubyinstaller-1.8.7-p249-rc2.exe"
Url = "http://rubyforge.org/frs/download.php/69034/" & Exe
Dst = "C:\Ruby"
Proxy = ""
If WScript.Arguments.Count = 1 Then
  Proxy = WScript.Arguments.Item(0)
  WScript.Echo "Using HTTP proxy=" & Proxy
End If

Set Shell = CreateObject("WScript.Shell")
Set Fs = CreateObject("Scripting.FileSystemObject")
If Fs.FileExists(Exe) Then
  WScript.Echo "Using existing " & Exe
Else
  WScript.Echo "Downloading " & Url
  Set Http = CreateObject("WinHttp.WinHttpRequest.5.1")
  If Proxy <> "" Then
     Http.setProxy 2, Proxy, ""
  End If
  Http.Open "GET", Url, False
  Http.Send
  Set BinaryStream = CreateObject("ADODB.Stream")
  BinaryStream.Type = 1
  BinaryStream.Open
  BinaryStream.Write Http.ResponseBody
  BinaryStream.SaveToFile Exe, 2
  BinaryStream.Close
End If

Ruby = Dst & "\bin\ruby.exe"

If Fs.FileExists(Ruby) Then
  WScript.Echo Dst & " exists"
Else
  WScript.Echo "Installing " & Exe & " to " & Dst
  Cmd = Exe & " /dir=" & Dst & " /verysilent /tasks=assocfiles,modpath"
  WScript.Echo Cmd
  Set Exec = Shell.Exec(Cmd)
  Do Until Exec.StdOut.AtEndOfStream
    Line = Exec.StdOut.ReadLine()
    Wscript.Echo Line
  Loop
End If

GemProxy = ""
If Proxy <> "" Then
  GemProxy = " --http-proxy=http://" & Proxy
End If

Cmd = Ruby & " " & Dst & "\bin\gem install" & GemProxy & " --no-ri --no-rdoc chef ruby-wmi windows-pr win32-open3 rubyzip"
WScript.Echo Cmd
Set Exec = Shell.Exec(Cmd)
Do Until Exec.StdOut.AtEndOfStream
  Line = Exec.StdOut.ReadLine()
  Wscript.Echo Line
Loop
Do Until Exec.StdErr.AtEndOfStream
  Line = Exec.StdErr.ReadLine()
  Wscript.Echo Line
Loop

