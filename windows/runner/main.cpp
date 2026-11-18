#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <shobjidl.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr wchar_t kTaskerAppUserModelId[] = L"KidOBricks.Tasker.Desktop";

void RegisterTaskerAppUserModelId() {
  SetCurrentProcessExplicitAppUserModelID(kTaskerAppUserModelId);

  HKEY aumid_key = nullptr;
  const wchar_t* aumid_path =
      L"Software\\Classes\\AppUserModelId\\KidOBricks.Tasker.Desktop";
  if (RegCreateKeyExW(HKEY_CURRENT_USER, aumid_path, 0, nullptr, 0, KEY_WRITE,
                      nullptr, &aumid_key, nullptr) == ERROR_SUCCESS) {
    const wchar_t display_name[] = L"Tasker";
    RegSetValueExW(aumid_key, L"DisplayName", 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(display_name),
                   sizeof(display_name));
    RegCloseKey(aumid_key);
  }

  HKEY notif_key = nullptr;
  DWORD disposition = 0;
  const wchar_t* notif_path =
      L"Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings\\KidOBricks.Tasker.Desktop";
  if (RegCreateKeyExW(HKEY_CURRENT_USER, notif_path, 0, nullptr, 0, KEY_WRITE,
                      nullptr, &notif_key, &disposition) == ERROR_SUCCESS) {
    if (disposition == REG_CREATED_NEW_KEY) {
      DWORD show_in_center = 1;
      RegSetValueExW(notif_key, L"ShowInActionCenter", 0, REG_DWORD,
                     reinterpret_cast<const BYTE*>(&show_in_center),
                     sizeof(show_in_center));
    }
    RegCloseKey(notif_key);
  }
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  RegisterTaskerAppUserModelId();

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Tasker", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
