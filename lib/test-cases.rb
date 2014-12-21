[['import \'a/a\' as b a.',
  "(import \"a/a\" b)\n(a)"],

 ['import \'b\' as b a.',
  "(import \"b\" b)\n(a)"],

 ['Test = read File.',
  '(define Test (read File))'],

 ['read with something.',
  '(read something)'],

 ['read.',
  '(read)'],

 ['Test = read File with something.',
  '(define Test (read File something))'],

 ['read File /tmp/test.txt.',
  '(read (File "/tmp/test.txt"))'],

 ['with something.',
  '(with "something")'],

 ['Test = read very http://example.com slowly File file:///tmp/test.txt with something.',
  '(define Test (read "very http://example.com slowly" (File "file:///tmp/test.txt") something))'],

 ['read very slowly.',
  '(read "very slowly")'],

 ['read very slowly with something.',
  '(read "very slowly" something)'],

 ['read very slowly with something else like this ftp://test.txt.',
  '(read "very slowly" (something "else like this ftp://test.txt"))'],

 ['Test = read File1 and File2 with something.',
  '(define Test (read File1 File2 something))'],

 ['Test = read File1 and File2[] and File3.',
  '(define Test (read File1 File2[] File3))'],

 ['Test = read File1 /tmp/test.txt and File2 with something.',
  '(define Test (read (File1 "/tmp/test.txt") File2 something))'],

 ['Test = read File1 /tmp/test.txt and File2 /tmp/test.aaa.',
  '(define Test (read (File1 "/tmp/test.txt") (File2 "/tmp/test.aaa")))'],

 ['T[] = read.',
  '(define T[] (read))'],

 ['read T[].',
  '(read T[])']]
