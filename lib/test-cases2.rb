[
  ["Test: read File.",
   "s(:activity, s(:variable, Test), s(:action, read), File)"],
  ["read with something.",
   "s(:activity, s(:action, read), s(:condition, something))"],
  ["read.",
   "s(:activity, s(:action, read))"],
  ["Test: read File with something.",
   "s(:activity, s(:variable, Test), s(:action, read), File, s(:condition, something))"],
  ["read File /tmp/test.txt.",
   "s(:activity, s(:action, read), File /tmp/test.txt)"],
  ["with something.",
   "s(:activity, s(:action, with, s(:action_arguments, something)))"],
  ["Test: read very http://example.com slowly File file:///tmp/test.txt with something.",
   "s(:activity, s(:variable, Test), s(:action, read, s(:action_arguments, very http://example.com slowly)), File file:///tmp/test.txt, s(:condition, something))"],
  ["read very slowly.",
   "s(:activity, s(:action, read, s(:action_arguments, very slowly)))"],
  ["read very slowly with something.",
   "s(:activity, s(:action, read, s(:action_arguments, very slowly)), s(:condition, something))"],
  ["read very slowly with something else like this ftp://test.txt.",
   "s(:activity, s(:action, read, s(:action_arguments, very slowly)), s(:condition, something, c(:condition_arguments, else like this ftp://test.txt)))"],
  ["Test: read File1 and File2 with something.",
   "s(:activity, s(:variable, Test), s(:action, read), File1 and File2, s(:condition, something))"],
  ["Test: read File1 /tmp/test.txt and File2 with something.",
   "s(:activity, s(:variable, Test), s(:action, read), File1 /tmp/test.txt and File2, s(:condition, something))"],
  ["Test: read File1 /tmp/test.txt and File2 /tmp/test.txt.",
   "s(:activity, s(:variable, Test), s(:action, read), File1 /tmp/test.txt and File2 /tmp/test.txt)"],
  ["T[]: read.",
   "s(:activity, s(:list_variable, T[]), s(:action, read))"],
  ["read T[].",
   "s(:activity, s(:action, read), s(:list_variable, T[]))"]]