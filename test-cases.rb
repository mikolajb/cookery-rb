{"Test: read File." => {
   variable: "Test",
   action: "read"},
 "read with something." => {
   action: "read",
   condition: "something"},
 "read\n\t." => {action: "read"},
 "Test: read File with something." => {
   variable: "Test",
   action: "read",
   subject: "File",
   condition: "something"},
 "Test: read File1 and File2 with something." => {
   variable: "Test",
   action: "read",
   subject: "File1, File2",
   condition: "something"},
 "read File /tmp/test.txt." => {
   action: "read",
   subject: "File",
   subject_arguments: "/tmp/test.txt"},
 "Test: read File1 /tmp/test.txt and File2 with something." => {
   variable: "Test",
   action: "read",
   subject: "File1, File2",
   subject_arguments: "/tmp/test.txt",
   condition: "something"},
 "Test: read File1 /tmp/test.txt and File2 /tmp/test.txt " \
 "with something." => {
   variable: "Test",
   action: "read",
   subject: "File1, File2",
   subject_arguments: "/tmp/test.txt, /tmp/test.txt",
   condition: "something"},
 "Test: read very http://example.com slowly File file:///tmp/test.txt with something." => {
   variable: "Test",
   action: "read",
   action_arguments: "very http://example.com slowly",
   subject: "File",
   subject_arguments: "file:///tmp/test.txt",
   condition: "something"},
 "read very slowly." => {
   action: "read",
   action_arguments: "very slowly"},
 "read very slowly with something." => {
   action: "read",
   action_arguments: "very slowly",
   condition: "something",
 },
 "read very slowly with something else like this ftp://test.txt." => {
   action: "read",
   action_arguments: "very slowly",
   condition: "something",
   condition_arguments: "else like this ftp://test.txt"
 },
 "T[]: read File /tmp/test.txt." => {
   action: "read",
   list_variable: "T[]",
   subject: "File",
   subject_arguments: "/tmp/test.txt"},
 "A[]: read T[]." => {
   action: "read",
   list_variable: "A[]",
   list_variable_body: "T[]"},
}
