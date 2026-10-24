import Foundation
@main struct TokenProbe {
 static func main() {
  let vectors: [(Double, String)] = [
   (0, "52BC7A17B50DFEC9-28C4394775C8751CD2F6859C030C06DB1489ACAB3B3A7651831FC26895177ED6"),
   (300, "F7535A20A262E331-28675BF85C7106BBF20035A78FCB0B6890813EAD5C3B983EF3424931B720BABB"),
   (1700000000, "2CD23A2CA0B2595A-F3C846C370E05F9CC83ACC5F995C5F5D87A4D0F14CE8936A0F902E64099E38A2"),
   (1792800000, "DE6718128A548C80-796F4E33820D2C549E1EF6D69C9A9756ADA63A487DEA0BD6A488E8DD685D7B97")
  ]
  for (t, expected) in vectors {
   let actual = edgeSecurityToken(unixTimestamp: t)
   precondition(actual == expected, "Mismatch at timestamp \(t): \(actual)")
  }
  precondition(edgeSecurityToken(unixTimestamp: 1791763200) == edgeSecurityToken(unixTimestamp: 1791763499.999))
  precondition(edgeSecurityToken(unixTimestamp: 1791763200) != edgeSecurityToken(unixTimestamp: 1791763500))
  precondition(edgeSecurityToken().count == 81)
  print("PASS: 4 independent JavaScript reference vectors; five-minute bucket boundaries; current-token format")
 }
}
