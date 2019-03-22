# randgen
Ultrain random number test

The purpose of this respository is to 
- demonstrate the core logic of how the random number is generated
- test the final randomness with NIST test suite


what's not included
- the Ultrain typescript smart contract, which generates randomness for the system and dapps
- much more sofisticated main pool & waiter pool to prevent collusion and denial-of-service
- pipelined structure for independent random number generation every block

how to use (ubuntu linux 18.04)
- install OpenSSL 1.1.0g or higher
- sudo apt-get install expect
- git clone https://github.com/wanghs09/randgen.git
- mkdir sts, download NIST test suite, available from the official website (https://csrc.nist.gov/projects/random-bit-generation/documentation-and-software)
- bash randgen.sh
- the final report is available in experiments/AlgorithmTesting/finalAnalysisReport.txt