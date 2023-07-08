use starknet::ContractAddress;

#[starknet::interface]
trait IStarkdex<TContractState> {
    fn get_reserve(self: @TContractState) -> u256;
    fn get_amount_of_tokens(self: @TContractState, input_amount: u256, input_reserve: u256, output_reserve: u256) -> u256;
    fn add_liquidity(ref self: TContractState, amount_of_token: u256, amount_of_eth: u256) -> u256;
    fn remove_liquidity(ref self: TContractState, amount: u256) -> (u256, u256);
    fn eth_to_token(ref self: TContractState, eth_sold: u256, min_tokens: u256);
    fn token_to_eth(ref self: TContractState, token_sold: u256, min_eth: u256);
}

#[starknet::contract]
mod Stardex {
    use traits::TryInto;
    use traits::Into;
    use option::OptionTrait;
    use starknet::ClassHash;
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const, get_contract_address};
    use starkdex::token::erc20::{IERC20Dispatcher, IERC20DispatcherTrait, IERC20LibraryDispatcher};
    use super::{IStarkdexDispatcher, IStarkdexDispatcherTrait, IStarkdexLibraryDispatcher};

    const FEE_DENOMINATOR: u256 = 1;

    #[storage]
    struct Storage {
        lp_token: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token: ContractAddress) {
        assert(!token.is_zero(), 'LP_TOKEN_CANNOT_BE_ZERO');
        self.lp_token.write(token);
    }

    #[external(v0)]
    impl StarkdexImpl of super::IStarkdex<ContractState> {
        fn get_reserve(self: @ContractState) -> u256 {
            let (token, _) = get_token_contract(self);
            token.balance_of(get_contract_address())
        }

        fn get_amount_of_tokens(self: @ContractState, input_amount: u256, input_reserve: u256, output_reserve: u256) -> u256 {
            assert(input_reserve > 0 && output_reserve > 0, 'INVALID_RESERVE');
            let input_amount_with_fee = input_amount * ((FEE_DENOMINATOR * input_amount) / 100);
            let numerator = input_amount_with_fee * output_reserve;
            let denominator = (input_reserve * 100) + input_amount_with_fee;
            numerator / denominator
        }

        fn add_liquidity(ref self: ContractState, amount_of_token: u256, amount_of_eth: u256) -> u256 {
            let (token, eth) = get_token_contract(@self);
            
            let mut lp_tokens_to_mint: u256 = 0_u256;
            let eth_balance: u256 = eth.balance_of(get_contract_address());
            let token_reserve_balance: u256 = IStarkdexDispatcher { contract_address: get_contract_address() }.get_reserve();
            
            if token_reserve_balance == 0 {
                token.transfer_from(get_caller_address(), get_contract_address(), amount_of_token);
                lp_tokens_to_mint = eth_balance;
                token.mint(get_caller_address(), lp_tokens_to_mint);
            } else {
                assert(eth.balance_of(get_caller_address()) >= amount_of_eth, 'INSUFFICIENT_ETH_BALANCE');
                let eth_reserve = eth_balance - amount_of_eth;
                let token_amount = (amount_of_eth * token_reserve_balance) / eth_reserve;

                assert(token_amount >= amount_of_token, 'INSUFFICIENT_TOKEN_BALANCE');
                token.transfer_from(get_caller_address(), get_contract_address(), token_amount);
                lp_tokens_to_mint = (token.total_supply() * amount_of_eth) / eth_reserve;
                token.mint(get_caller_address(), lp_tokens_to_mint);
            }
            lp_tokens_to_mint
        } 

        fn remove_liquidity(ref self: ContractState, amount: u256) -> (u256, u256) {
            assert(amount > 0, 'AMOUNT_CANNOT_BE_ZERO');
            let (token, eth) = get_token_contract(@self);
            let eth_reserve: u256 = eth.balance_of(get_contract_address());
            let total_supply: u256 = token.total_supply();
            let eth_amount = (eth_reserve * amount) / total_supply;
            let token_reserve_balance: u256 = IStarkdexDispatcher { contract_address: get_contract_address() }.get_reserve();
            let token_amount = (token_reserve_balance * amount) / total_supply;

            token.burn(get_caller_address(), amount);
            eth.transfer(get_contract_address(), eth_amount);
            token.transfer(get_caller_address(), token_amount);
            (eth_amount, token_amount)
        }

        fn eth_to_token(ref self: ContractState, eth_sold: u256, min_tokens: u256) {
            let (token, eth) = get_token_contract(@self);
            let token_reserve_balance: u256 = IStarkdexDispatcher { contract_address: get_contract_address() }.get_reserve();
            assert(eth.balance_of(get_contract_address()) >= eth_sold, 'INSUFFICIENT_ETH_BALANCE');
            
            let token_contract_balance = token.balance_of(get_contract_address());
            let tokens_bought = IStarkdexDispatcher { contract_address: get_contract_address() }
                .get_amount_of_tokens(eth_sold, token_contract_balance, token_reserve_balance);
            assert(tokens_bought >= min_tokens, 'INSUFFICIENT_TOKENS_BOUGHT');

            token.transfer(get_caller_address(), tokens_bought);
        }

        fn token_to_eth(ref self: ContractState, token_sold: u256, min_eth: u256) {
            let (token, eth) = get_token_contract(@self);
            let token_reserve_balance: u256 = IStarkdexDispatcher { contract_address: get_contract_address() }.get_reserve();
            assert(token.balance_of(get_contract_address()) >= token_sold, 'INSUFFICIENT_ETH_BALANCE');

            let token_contract_balance = token.balance_of(get_contract_address());
            let eth_bought = IStarkdexDispatcher { contract_address: get_contract_address() }
                .get_amount_of_tokens(token_sold, token_reserve_balance, token_contract_balance);
            assert(eth_bought >= min_eth, 'INSUFFICIENT_ETH_BOUGHT');

            token.transfer_from(get_caller_address(), get_contract_address(), token_sold);
            eth.transfer(get_caller_address(), eth_bought);
        }

    }

    fn get_token_contract(self: @ContractState) -> (IERC20Dispatcher, IERC20Dispatcher)  {
        (
            IERC20Dispatcher { contract_address: self.lp_token.read() },
            IERC20Dispatcher { contract_address: contract_address_const::<0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7>() },
        )
    }
    
}