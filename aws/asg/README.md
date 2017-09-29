# Auto-scaling groups (ASGs)
These scripts enable PX-ready clusters to be deployed using ASGs

Noteworthy here:
* The "pub_key" variable is inserted into the "root" authorized keys, enabling direct "ssh root" access.
* Security group allows all internal access, but only ports 22, 80, 443, 8080 externally
* Currently hardcodes the Ubuntu16 ami
