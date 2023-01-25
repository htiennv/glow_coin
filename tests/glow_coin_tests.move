#[test_only]
module glow_address::glow_coin_tests {
    use aptos_framework::account;
    use aptos_framework::coin;

    use glow_address::glow_coin::{Self, GlowCoin};

    #[test(admin = @glow_address)]
    fun test_mint_burn_coins(admin: signer) {
        glow_coin::initialize(&admin);

        let user_addr = @0x41;
        let user = account::create_account_for_test(user_addr);
        coin::register<GlowCoin>(&user);
        glow_coin::mint(&admin, user_addr, 100);

        assert!(coin::balance<GlowCoin>(user_addr) == 100, 1);

        glow_coin::burn(&user, 30);

        assert!(coin::balance<GlowCoin>(user_addr) == 70, 1);
    }
}