#reference_monitor
## Reference Monitor
- **purpose** - ensures enforcement of security goals
	- *[[Mandatory Protection|mandatory protection state]]* defines goals
	- reference monitor ensures *[[Enforcement|enforcement]]*
- every components that you **depend** on to enforce your security goals must be enforced by a **reference monitor**
- **components**
	- reference monitor interfaces
		- e.g. [[SELinux|Linux Security Modules]]
	- authorization module
		- e.g. [[SELinux|SELinux]]
	- policy store
		- e.g. policy binary
### Guarantees
- ***complete mediation, tamperproof, and verifiable***
- **complete mediation** - reference validation mechanism must always be invoked
	- every security-sensitive operation must be *mediated*
		- *security-sensitive operation* - an operation that enables a subject of one label to access an object that may be a different label
	- **validating**
		- every security-sensitive operation must be identified
		- then check for *dominance* of mediation
	- **main questions**
		- does interface mediate correctly?
		- on all resources?
		- verifiably?
- **tamperproof** - reference validation mechanism must be secure against modification
	- prevent modification by untrusted entities
		- interface, mechanism, and policy of a reference monitor
		- code and policy that can affect reference monitor
	- detecting
		- *transitive closure* of operations
		- often some untrusted operations are present, posing a challenge
	- **main questions**
		- is reference monitor protected?
		- is system [[Enforcement|TCB]] protected?
- **verifiable** - reference validation mechanism must be subject to analysis and tests, the completeness of which must be assured
	- test and analyze
		- reference validation mechanism
		- tamperproof dependencies
		- security goals the system enforces
	- determining the correctness of the code and policy
		- how do we define correctness for each?
	- **main questions**
		- is TCB code base correct?
		- does the protection system enforce the system's security goals
### Evaluation
- evaluation based on the **main questions**
	- mediation - does interface mediate correctly?
	- mediation - on all resources?
	- mediation - verifiably?
	- tamperproof - is reference monitor protected?
	- tamperproof - is system TCB protected?
	- verifiable - is TCB code base correct?
	- verifiable - does the protection system enforce the system's security goals?
### Multiple Reference Monitors
- original reference monitor concept approached designed with a centralized reference validation mechanism n mind
- what happens if we have several of these mechanisms grouped together?
	- how to reason their composability?


     #multics #multics/protection_ring
## Overview
- **integrity** for [[Multics|multics]]
- successively less-privileged domains
- multics had 64 rings in theory, 8 in practice
- in modern processors, 4 rings but only 2 are in general use
	- **ring 0** - kernel mode
	- **ring 3** - user mode
### Ring Brackets
- kernel resides in **ring 0**
- process resides in **ring $r$**
	- access is based on *current ring*
- process accesses data (segment)
	- each data segment has an **access bracket** $(a_1,a_2)$
	- **access bracket relationship** - $a_1 \leq a_2$
	- describes read and write access to the *current ring*
- given the **current ring $r$**
	- *access permitted* - $r \leq a_1$
	- *read and execute permitted, write denied* - $a_{1}\leq r\leq a_{2}$
	- *all access denied* - $a_{2}\leq r$
### Process Invocation
- program cannot call code of **higher privilege** *directly*
- **gate** - mediates access
	- *special memory address* where lower-privilege code can call higher-privilege functions or code
	- enables the os to control where applications call *privileged functionality*
	- in modern oses, equivalent to system calls
#### Brackets
- different procedure segments with
	- **call brackets** $(c_{1},c_{2})$ where $c_{1}\leq c_{2}$
	- **access brackets** $(a_{1},a_{2})$
- **rights** to execute in a procedure segment
	- $r\leq a_{1}$ - access permitted with a *ring-crossing fault*
		- ring-crossing fault changes the procedure's ring, increases from $r$ to $a_{1}$
	- $a_{1}\leq r\leq a_{2}=c_{1}$ - access permitted and *no fault*
		- $r$ keeps the same ring number
	- $a_{2}<r\leq c_{2}$ - access permitted through a *valid gate*
		- arguments are checked by the gate, ring number is decreased
	- $c_{2}<r$ - access *denied*
- **examples**
	- process in ring 3 accesses data segment
		- access bracket - (2, 4)
		- operations - @todo
	- process in ring 5 accesses same data segment
		- operations - @todo
	- process in ring 5 accesses procedure segment
		- access bracket (2, 4) and call bracket (4, 6)
		- @todo
		- can call be made?
		- determining new ring
		- new proc segment access above data segment
#### Brackets as MPS
- **protection state**
	- rings are fixed in hierarchy
	- protection state can be modified by the owner
- **labeling state**
	- ring determined statically
	- default can be changed as above
- **transition state** - through call brackets, guarded by gates


#access_control #access_control/models #access_control/models/lattice
## Lattice Models
- **Hasse diagram** - represents security lattices
	- represents a finite poset as a directed graph of its transitive reduction
		- minimum representation of edges
- subjects and objects have security levels and optional categories
- **confidentiality policy** - e.g. [[Multilevel Security|BLP]]
	- **simple property** - may read only if the subject's security level dominates the object's security level
		- *read-down*
	- **star-property** - may write only if the subject's security level is dominated by the object's security level
		- *write-up*
	- **tranquility property** - may not change the security level of an object concurrent to its use
	- can prove that a system which starts in a **secure state** will *remain* in one
## Objections to BLP
- some processes need to read and write at all levels
	- e.g. memory management
	- **fix** - put them in [[Enforcement|tcb]]
	- **consequence** - once you put in all the stuff a real system needs, the tcb is no longer small enough to be *easily verifiable*
- **system z** - blp but let users request *temporary declassification* of any file
	- this is a cheat but technically not disallowed by the model
	- **fix** - add *tranquility principles*
		- *strong tranquility* - labels never change
		- *weak tranquility* - they do not change in a way to break the security policy
	- usually choose **weak tranquility** using the **high watermark** principle
		- process acquires the highest label of any resource its touched
		- **problem** - have to rewrite apps
- high cannot acknowledge receipt from low
	- **blind write-up** - often inconvenient because info vanishes into a black hole
	- **option 1** - accept this and engineer for it (*morris theory*)
	- **option 2** - allow acks, but be aware that they might be used by high to signal to low
	- use some combination of software trust and covert channel elimination
### Covert Channels
- concerns blp might be impractical because of **covert channels**
	- neither designed nor intended to carry info at all
- trojan at high signals to a buddy at low by modulating a shared system resource
	- **storage channel** - fills the disk
	- **timing channel** - loads the cpu
- **capacity** - depends on bandwidth and S/N
	- solution - cut the bandwidth or increase the noise
	- hard to get below 1bps
## Biba
- need to look at integrity
- [[Multilevel Security|mls]] talks about who can read a document
	- *confidentiality*
- **integrity** considers who can *write* to a document
	- who can affect the integrity (content) of a document
- **Biba** - blp's integrity counterpart
- **lattice policy** with *no write down, no read up*
- user only **creates** content *at or below* their integrity level
- user only **accesses** content *at or above* their own integrity level
## Biba vs BLP
- **blp**
	- prevent trojan horses from leaking information to lower security levels
	- mandatory access control and implicit constraints
- **biba**
	- prevent low integrity info flows to higher integrity processes
- categories and compartments for separation within levels
- safety is **implicit** in the model
	- no additional constraints are needed to express security guarantees
## Security Lattices
- given a set of classifications $C$ and categories $K$
- set of security levels $L=C \times K, dom$ forms a **lattice**
- security levels defined in terms of **least upper bound (supremum)** and **greatest lower bound (infimum)**
	- $lub(L)=max(A,C)$
	- $glb(L)=min(A,\emptyset)$
- security levels form a **partially ordered set (poset)**
	- every element has a security level and corresponding supremum and infimum
	- describes a lattice
## Denning's Lattice Model
- formalizes **information flow models**
	- $FM=\{N,P,SC,\oplus,\rightarrow\}$
- shows that the information flow model instances form a **lattice**
	- $\{SC,\rightarrow\}$ is a *partial order set*
		- reflexive
		- transitive
		- anti-symmetric
	- $SC$ is *finite*
		- compare to protection systems and safety problem
	- $SC$ has a *lower bound*
	- $\oplus$ is a $lub$ operator
		- defined for any pair in $SC$
- **implicit and explicit** info flows
	- *explicit* - direct transfer to $b$ from $a$
		- e.g. $b=a$
	- *implicit* - where the value of $b$ may depend on the value of $a$ indirectly
		- e.g. if $a=0$, then $b=c$
		- only occur in *conditionals*
	- model covers *all* programs
		- statement $S$
		- sequence $S_{1}, S_{2}$
		- conditional $c:S_{1},\dots,S_{m}$
- semantics for verifying that a configuration is secure
	- program is secure if
		- explicit flow from $S$ is secure
		- explicit flow of all statements in a sequence are secure
			- e.g. $S_{1};S_{2}$
		- conditional $c:S_{1},\dots,S_{m}$ is secure if
			- explicit flows of all statements $S_{1},\dots,S_{m}$ are secure
			- implicit flows between $c$ and the objects in $S_{i}$ are secure
- static and dynamic binding considered
	- **static binding** - security class of an object is *fixed*
		- true for blp and biba, but not for all system models
	- **dynamic binding** - security class of an object can *change*
		- for $b=a$, then the security class of $b$ is $b\oplus a$
		- *rare* approach
- biba and blp are *simplest models* of this type
- possible operations
	- if $f(a_{1},\dots,a_{n})\rightarrow b$, then $a_{1}\oplus\dots\oplus a_{n}\rightarrow b$
- the **combination** of $a_{1}\dots a_{n}$ is *authorized* to flow to $b$
## BPL Variants
- **noninterference** - no input by high can affect what low can see
	- whatever trace there is for high input $X$, there is a trace with high input $\emptyset$ that looks the same to low
- **nondeducibility** - weakens this so that low is allowed to see high data
	- cannot understand that data though, e.g. it is encrypted
- **composability** - systems can become *insecure* when interconnected or when feedback is added
	- **noninterference and nondeducibility** do not compose
	- lot of things can go wrong
		- e.g. clash of timing mechs, interaction of ciphers, interaction of protocols
	- *practical problem* - lack of good security interface definitions
	- labels can depend on data volume or even be non-monotone
- **domain and type enforcement (dte)** - subjects are in [[Type Enforcement|domains]], objects have types
	- subject type can access object type to perform operations on objects
- **role based access control (rbac)** - [[Role Based Access Control|current]] fashionable policy framework
- **group and attributes** - user group has access to objects with the attribute
## Clark-Wilson Integrity Model
- **information flow plus models** - biba info flow models *insufficient for integrity*
	- there are more concrete, domain specific definitions
	- integrity of data in commercial environments should be maintained by well-formed transactions
	- how do we model commercial integrity?
		- **clark wilson**
- **clark-wilson integrity model**
	- *motivation* - previous models are fine for military security scenarios where the policies are designed to regulate control of classified information
	- in *commercial security* scenarios, preventing disclosure is important but preventing data modification is most critical
	- biba-like models require trusted admin or trusted process to *declassify* low integrity to high integrity data
	- *argument* - this happens outside the security model but data input is so important in systems that this procedure should be reflected inside it
- **motivation** - integrity is defined as a set of constraints and data is in a *consistent* or valid state when these constraints are satisfied
	- a *well-formed transaction* moves the system from one consistent state to another
	- **but**, who examines and certifies that transactions happen correctly?
- **entities**
	- **constrained data items (cdi)** - high integrity data objects, subject to integrity controls
	- **unconstrained data items (udi)** - low integrity data object, not subject to integrity controls
	- **integrity verification procedures (ivp)** - high integrity processes to test that cdis conform to integrity cosntraints
	- **transaction/transformation procedures (tp)** - high integrity processes that take system from one valid state to another
- **premise**
	- ivps verify initial integrity of high integrity data cdis
	- cdis are only modified by tps
	- udis that are actually high integrity can be certified by tps and become cdis
	- if all of the above are met, then the integrity of computation is *preserved*
- **requirements**
	- integrity of constrained data must be verified before use
	- high integrity data may only be modified by *transformation procedures* that implement *well-formed transactions*
- **endorsement and certification rules**
	- **c1** - when an ivp is executed, it must ensure the cdis are valid
	- **c2** - for some associated set of cdis, a tp must transform those cdis from one valid state to another
		- since we must make sure that these tps are **certified** to operate on a particular cdi, we must have e1 and e2, **authorization rules**
	- **e1** - system must maintain a list of certified relations and ensure only tps certified to run on a cdi change that cdi
	- **e2** - system must associate a user with each tp and set of cdis, the tp may access the cdi on behalf of the user if it is "legal"
		- requires keeping track of *allowed relations* - (user, tp, {cdis})
	- **c3** - allowed relations must meet the requirements of *separation of duty*
		- requires separating certification from use, so we need *authentication* of users to keep track of this
	- **e3** - system must authenticate every user attempting a tp
		- keep an **audit log** for security purposes
	- **c4** - all tps must append to a log enough information to reconstruct the operation
		- have to appropriately deal with info entering the system as it is not trusted or constrained
	- **c5** - any tp that takes a udi as input may only perform valid transactions for all possible values of the udi, with the tp then accepting, which coverts it to a cdi, or rejecting the udi
		- need to prevent people from gaining access by changing qualifications of a tp
	- **e4** - only the certifier of a tp may change the list of entities associated with that tp
- in basic terms, a user can access a cdi using a tp if and only if
	- the user has been granted cdi access
	- the tp has been granted cdi access
	- the user has been granted access to the tp
- security depends on certification of the properties, but *no method* for certification is provided by the model
## Low Water Mark Integrity (LOMAC)
- integrity level is not statically defined but changes based on actual dependencies
- subject usually starts at highest integrity level
- integrity level changes based on objects accessed
- **self-revocation** - subject has integrity of the lowest object read
- **example**
	- level 1 - low integrity objects
	- level 2 - high integrity objects
	- user processes start at level 2
	- **without lomac** - if $J$ downloads content containing trojan horse
		- trojan horse can use buffer overflow attack to take control of $J$ and write out to objects not normally writeable
	- **with lomac** - $O_{1}$ is a level 2 object, so $J$ starts at level 2
		- $J$ demoted to level 1 if they download content, especially that carrying a trojan horse
		- trojan horse uses buffer overflow to take control of $J$
		- $J$ can no longer access $O_{1}$ because of demoted integrity level

|       | $O_1$ | $O_2$ | $O_3$ |
|:-----:|:-----:|:-----:|:-----:|
|  $J$  |   R   |  RW   |  RW   |
| $S_2$ |   -   |   R   |  RW   |
| $S_3$ |   -   |   R   |  RW   |
## Chinese Wall Model
- only allow subjects to read data from one of the conflicting parties
	- also need to control writing
- **company dataset** $CD(0)$ - set of objects that may belong to a company
- **conflict of interest class** $COI(0)$ - datasets of companies in conflict, each object has only one
- read if and only if
	- $PR(S)$ is subject of objs that a subject $S$ has already read
	- cw-simple security property
		- if subject $S$ reads object $O$ belonging to dataset $CD$, she can never read another $O'$ where $CD(0')$ is a member of $COI(0)$ and $CD(O')\neq CD(0)$
		- objects can be *sanitized*
- **writer** only accesses objects in one dataset