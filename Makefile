-include .env

all: clean update build

# Clean the repo
clean :;
	@forge clean

# Install dependencies
install :;
	@forge install

# Update dependencies
update :;
	@forge update

# Build the project
build :;
	@forge build

# Format code
format:
	@forge fmt

# Lint code
lint:
	@forge fmt --check

# Run tests
tests :;
	@forge test -vvv --ffi --match-contract=YakyukenTests

# Run the tests no match with CI
tests-ci :; 
	@forge test -vvv --no-match-test "SkipCI"

# Run tests with coverage
coverage :;
	@forge coverage

# Run tests with coverage and generate lcov.info
coverage-report :;
	@forge coverage --report lcov

# Run slither static analysis
slither :;
	@slither ./src

documentation :;
	@forge doc --build

# Deploy a local blockchain
anvil :;
	@anvil -m 'test test test test test test test test test test test junk' 

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :;
	@forge script script/01_Deploy.s.sol:Deploy --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --ffi --broadcast

# Deploy the contract to remote network and verify the code
deploy-network :;
	@export FOUNDRY_PROFILE=deploy && \
	forge script script/01_Deploy.s.sol:Deploy -f ${network} --broadcast --verify --delay 20 --retries 10 -vvvv --ffi && \
	export FOUNDRY_PROFILE=default

run-script :;
	@export FOUNDRY_PROFILE=deploy && \
	./utils/run_script.sh && \
	export FOUNDRY_PROFILE=default

run-script-local :;
	@./utils/run_script_local.sh

generate :;
	@forge script script/00_Generate.s.sol:GenerateScript --ffi
