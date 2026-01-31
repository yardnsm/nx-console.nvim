local M = {}

---@enum nx_console.NotificationType
M.notification_types = {
  NxWorkspaceChangeNotification = "nx/changeWorkspace",
  NxWorkspaceRefreshNotification = "nx/refreshWorkspace",
  NxWorkspaceRefreshStartedNotification = "nx/refreshWorkspaceStarted",
}

---@enum nx-console.RequestType
M.request_types = {
  NxStopDaemonRequest = "nx/stopDaemon",
  NxGeneratorsRequest = "nx/generators",
  NxProjectFolderTreeRequest = "nx/projectFolderTree",
  NxProjectByPathRequest = "nx/projectByPath",
  NxProjectByRootRequest = "nx/projectByRoot",
  NxVersionRequest = "nx/version",
  NxWorkspaceRequest = "nx/workspace",
}

return M
