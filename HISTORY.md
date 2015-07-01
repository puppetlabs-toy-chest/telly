# default - History
## Tags
* [LATEST - 1 Jul, 2015 (3dfb6906)](#LATEST)
* [0.1.2 - 17 Feb, 2015 (7ed8f7e1)](#0.1.2)
* [0.1.1 - 26 Jan, 2015 (b88029bd)](#0.1.1)

## Details
### <a name = "LATEST">LATEST - 1 Jul, 2015 (3dfb6906)

* (GEM) update telly version to 0.2.0 (3dfb6906)

* Merge pull request #9 from anodelman/gem (afa8ab0c)


```
Merge pull request #9 from anodelman/gem

(MAINT) bad version number, accidental copy-paste from another project
```
* (MAINT) bad version number, accidental copy-paste from another project (0e3c092d)


```
(MAINT) bad version number, accidental copy-paste from another project

- should be at current released version 0.1.2
```
* (QENG-2616) Telly - Cannot Find Test Files Using Beaker... (55c17375)


```
(QENG-2616) Telly - Cannot Find Test Files Using Beaker...

... 2.8+ Logs/JUnit Reports

- beaker added a directory level that telly couldn't handle
- addeds support for --dry-run, which just process the junit file
  without creating a TestRail api connection or attempting to submit
  results
```
* (QENG-2195) add telly jenkins release pipeline (5d0ef508)


```
(QENG-2195) add telly jenkins release pipeline

- add spec test rake task
```
* (QENG-2195) add telly jenkins release pipeline (f74a0c79)


```
(QENG-2195) add telly jenkins release pipeline

- standardized gem workflow
```
### <a name = "0.1.2">0.1.2 - 17 Feb, 2015 (7ed8f7e1)

* Merge pull request #5 from colinPL/maint_v0.1.2_gem (7ed8f7e1)


```
Merge pull request #5 from colinPL/maint_v0.1.2_gem

(GEM) Update telly version to 0.1.2
```
* (GEM) Update telly version to 0.1.2 (8bb2f561)

* Merge pull request #4 from jpinsonault/QENG-1796-improve-error-recovery (2d825896)


```
Merge pull request #4 from jpinsonault/QENG-1796-improve-error-recovery

(QENG-1796) Improved error recovery
```
* Created custom exception, better rescuing (e23c82c0)

* (QENG-1796) Improved error recovery (a3161911)


```
(QENG-1796) Improved error recovery
Previously only testrail api errors were caught and shown to the
user, now any exception that happens during submission is caught
and that test is reported to the user.

In addition, when a beaker test file doesn't contain a testcase id
it raises an exception with an appropriate error.

This PR was motivated by pre-suites not having testcase ids
causing the script to throw an uncaught exception
```
### <a name = "0.1.1">0.1.1 - 26 Jan, 2015 (b88029bd)

* Initial release.
