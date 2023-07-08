use serde::Serde;
use array::ArrayTrait;
use traits::Into;
use traits::TryInto;
use option::OptionTrait;
use result::ResultTrait;

use debug::PrintTrait;

use starkdex::token::erc20::{IERC20Dispatcher, IERC20DispatcherTrait, ERC20};
use starkdex::starkdex::{IStarkdexDispatcher, IStarkdexDispatcherTrait, IStarkdexLibraryDispatcher, Stardex};
use starknet::{get_contract_address, call_contract_syscall, deploy_syscall, ClassHash, contract_address_const, ContractAddress, ContractAddressIntoFelt252};

fn deploy_token(name: felt252, symbol: felt252) -> (ContractAddress, IERC20Dispatcher) {
    let mut constructor_args: Array<felt252> = ArrayTrait::<felt252>::new();
    constructor_args.append(name);
    constructor_args.append(symbol);

    let account: ContractAddress = contract_address_const::<1>();
    let (address, _) = deploy_syscall(ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), false).unwrap();
    (account, IERC20Dispatcher { contract_address: address })
}

fn deploy_starkdex(token: ContractAddress) -> IStarkdexDispatcher {
        let mut constructor_args: Array<felt252> = ArrayTrait::new();
    Serde::serialize(@token, ref constructor_args);

    let (address, _) = deploy_syscall(Stardex::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), false).unwrap();
    IStarkdexDispatcher { contract_address: address }
}

fn set_caller_as_zero() {
    starknet::testing::set_contract_address(contract_address_const::<0>());
}

#[test]
#[available_gas(3000000)]
fn test_deploy_constructor() {
    let (_, token) = deploy_token('stETH', 'stETH');
    let starkdex = deploy_starkdex(token.contract_address);

    assert(token.name() == 'stETH', 'name');
    assert(token.symbol() == 'stETH', 'symbol');
}