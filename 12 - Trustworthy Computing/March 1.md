## Trusted Boot Process
- **secure boot** - enforces requirements and uses special hardware to ensure a specific system is booted
	- implied verification
- by contrast, can measure each stage and have a verifier *authenticate* the correctness of the stage
	- **authenticated boot**
	- if root of trust is compromised and allowed to boot, secure boot will still go through
		- auth boot will not boot
	- why auth boot over secure boot
		- third party verifier - maybe harder to compromise
	- verifier must know how to verify correctness
- tpm - made auth boot mainstream
	- measurement, crypto, key gen, prng
	- controlled by physical presence of machine
	- bios is core root of trust for measurement
	- spec only discussed how to measure early boot phases and general userspace measurements
	- tamper-resistant
	- cheap
	- manages crypto keys and functionality it uses to support security relevant operations
	- measures code loaded by the system
	- measurements are hashes of loaded code (platform configuration registers - pcrs)
	- private key soldered into chip
	- acts as core root of trust
- auth boot - generated lot of discussion
	- palladium arch - dev by microsoft
	- lot of fear or uncertainity around it
	- could use tpm to ensure system is trusted
- implications of having a third party verifier
	- content providers have huge interest in auth boot
		- e.g. netflix does some integrity verification on streaming
		- allow you to play content on computer only if computer runs these types of software
- fun fact - windows 11 requires a semi-modern tpm to even use
## Integrity Measurement
- determine state of host
- performed by quote operation - lot of hashes
- ima impl
	- place hooks throughout linux kernel
	- extend tpm pcr at file load time
	- has rootkit compromise analysis
	- limitations
		- 