let getPrettyTitle = (routeName: string) => {
  switch routeName {
  | "BackupPhrase" => "Backup phrase"
  | "CreateAccount" => "Create account"
  | "ScanQR" => "Scan QR code"
  | "OffboardWallet" => "Offboard wallet"
  | "ChangePassword" => "Change password"
  | _ => routeName
  }
}
