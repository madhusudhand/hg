  $ hg init
  $ echo "nothing" > a
  $ hg add a
  $ hg commit -m ancestor
  $ echo "something" > a
  $ hg commit -m branch1
  $ hg co 0
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ echo "something else" > a
  $ hg commit -m branch2
  created new head

  $ hg merge 1
  merging a
  warning: conflicts during merge.
  merging a incomplete! (edit conflicts, then use 'hg resolve --mark')
  0 files updated, 0 files merged, 0 files removed, 1 files unresolved
  use 'hg resolve' to retry unresolved file merges or 'hg update -C .' to abandon
  [1]

  $ hg id
  32e80765d7fe+75234512624c+ tip

  $ cat a
  <<<<<<< local: 32e80765d7fe - test: branch2
  something else
  =======
  something
  >>>>>>> other: 75234512624c  - test: branch1

  $ hg status
  M a
  ? a.orig

Verify custom conflict markers

  $ hg up -q --clean .
  $ printf "\n[ui]\nmergemarkertemplate={author} {rev}\n" >> .hg/hgrc

  $ hg merge 1
  merging a
  warning: conflicts during merge.
  merging a incomplete! (edit conflicts, then use 'hg resolve --mark')
  0 files updated, 0 files merged, 0 files removed, 1 files unresolved
  use 'hg resolve' to retry unresolved file merges or 'hg update -C .' to abandon
  [1]

  $ cat a
  <<<<<<< local: test 2
  something else
  =======
  something
  >>>>>>> other: test 1

Verify line splitting of custom conflict marker which causes multiple lines

  $ hg up -q --clean .
  $ cat >> .hg/hgrc <<EOF
  > [ui]
  > mergemarkertemplate={author} {rev}\nfoo\nbar\nbaz
  > EOF

  $ hg -q merge 1
  warning: conflicts during merge.
  merging a incomplete! (edit conflicts, then use 'hg resolve --mark')
  [1]

  $ cat a
  <<<<<<< local: test 2
  something else
  =======
  something
  >>>>>>> other: test 1

Verify line trimming of custom conflict marker using multi-byte characters

  $ hg up -q --clean .
  $ python <<EOF
  > fp = open('logfile', 'w')
  > fp.write('12345678901234567890123456789012345678901234567890' +
  >          '1234567890') # there are 5 more columns for 80 columns
  > 
  > # 2 x 4 = 8 columns, but 3 x 4 = 12 bytes
  > fp.write(u'\u3042\u3044\u3046\u3048'.encode('utf-8'))
  > 
  > fp.close()
  > EOF
  $ hg add logfile
  $ hg --encoding utf-8 commit --logfile logfile

  $ cat >> .hg/hgrc <<EOF
  > [ui]
  > mergemarkertemplate={desc|firstline}
  > EOF

  $ hg -q --encoding utf-8 merge 1
  warning: conflicts during merge.
  merging a incomplete! (edit conflicts, then use 'hg resolve --mark')
  [1]

  $ cat a
  <<<<<<< local: 123456789012345678901234567890123456789012345678901234567890\xe3\x81\x82... (esc)
  something else
  =======
  something
  >>>>>>> other: branch1

Verify basic conflict markers

  $ hg up -q --clean 2
  $ printf "\n[ui]\nmergemarkers=basic\n" >> .hg/hgrc

  $ hg merge 1
  merging a
  warning: conflicts during merge.
  merging a incomplete! (edit conflicts, then use 'hg resolve --mark')
  0 files updated, 0 files merged, 0 files removed, 1 files unresolved
  use 'hg resolve' to retry unresolved file merges or 'hg update -C .' to abandon
  [1]

  $ cat a
  <<<<<<< local
  something else
  =======
  something
  >>>>>>> other
