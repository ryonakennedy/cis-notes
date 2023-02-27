#access_control/unix #access_control/acl #permissions
## Linux Permission Checking
- **[[UNIX Access Control|permissions]]** checked when a pathname is specified in a system call for accessing a file or directory
- **kernel process**
	- grant all access if the calling process is *privileged*
	- if effective user id of process is same as user id of file, grant access according to the *owner* permissions
	- if effective group id of process is same as group id of file, grant access according to *group* permissions
	- otherwise grant permission according to *other* permissions on file
- [[Windows Access Control|access control lists]] are supported in kernel v2.6+
	- not POSIX standard
	- filesystem needs to be *mounted* with appropriate options
### access System Call
- **`access`** - used to check **file accessibility** based on *real* user id and group id of process
- [[Vulnerabilities|TOCTTOU]] - no guarantee information returned by `access` will still be true before a subsequent operation
- **vulnerability**
	- setuid root program checks if file is *accessible* to real user id of program using `access`
	- pathname given is a *symlink*
	- user changes link to refer to different file before `access` completes
	- now setuid on a different file
- **issue** - system calls are *atomic*, sequences of them are not
#### Proposed Solution
- fixing the problem *deterministically* would require changing the kernel
	- doing it *probabilistically* could be portable without messing with system call interface
- **hardness amplification** - repeat access check multiple times
	- for $k$ checks, adversary needs to win $2k+1$ races
- **testing** - hard to win on uniprocessor, easy to win on multiprocessor
- winning numerous races *should* be hard
- easy if
	- avoid filesystem caching
		- put the symlinks in a bunch of different directories for the file you are attacking
	- update `atime` so that the attacker knows when a system call begins
	- slow down i/o operations with a deep tree of nested directories
	- use `/proc` to read system call number or determine if effective and real user id are the same in `/proc/pid/status`
		- indicates a call to `access`
- **filesystem maze** - deep tree of nested directories
	- chains of links between original and target
	- *time-consuming* - every directory has to be checked and accessed
		- if at least one directory in the chain is not in the *buffer cache*, victim has to sleep on i/o
	- can construct a filename that requires loading a lot of data from disk to resolve
	- lots of time for attacker to *replace link*
- with **determinism** - win races 22-100%
- with **randomness** - win races 19-88%
	- both with $k=100$
#### More Realistic Solutions
- do not use `access` any more, rely on os to enforce permission check
	- issue when program is using setuid since permission checks happen against effective user id/group id
- fork new processes and drop setuid to run with rights of the invoker to ensure that you should have access in the first place
	- fork before open is slow, but still faster than $k=100$
- allow **system transactions** - enclose code regions with consistency constraints with new system calls `sys_xbegin` and `sys_xend`
	- requires new inode structures with *spinlocks*
	- 8500 lines of code for transaction and object management
	- 14,000 lines of code for other changes to convert kernel code
	- average overhead of 6.6x compared to base linux (7x on read)