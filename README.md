# LWE-Encryption-Accelerator
In Silicon Post-Quantum Encryption Accelerator based on Learning with Errors

## Introduction
Asymmetric encryption is an essential technology in today's hyperconnected society. We rely on asymmetric encryption schemes to secure our communications every day. We also rely on asymmetric encryption in cutting edge finance tech as it fundamentally enables authenticating transactions on the blockchain. Current asymmetric encryption schemes are vulnerable to attacks from quantum computers via Shor's Algorithm. The theory for this algorithm has existed for quite a while now, but no quantum computer sufficiently capable of utilizing the algorithm at production scale has yet to be constructed. Regardless, it is important that we ensure that our encryption schemes are quantum computer resistant since encrypted data can be collected today and stored until sufficient compute resources exist to decrypt the data. As such, many so called "post-quantum" encryption schemes have been invented and even implemented in production.

The extreme frequency at which today's large data centers compute asymmetric encryption kernels combined with the computational complexity of said kernels establish a great need for hardware accelerators for this task. By moving these kernels to dedicated hardware, we have been able to slash power consumption and computation time required for encryption workloads.

As we begin to migrate towards post-quantum encryption schemes, new accelerator architecture will need to be developed to support said schemes. Several published papers have recognized this need and have demonstrated significant speed-ups by deploying to FPGA's, but to the author's best knowledge, the field has yet to explore the potential for speed-ups and efficiency boosts from implementing these accelerators in silicon. This work aims to evaluate silicon implementations of lattice based encrytion schemes.

## Implementation


