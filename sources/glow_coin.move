module glow_address::glow_coin {
    use std::signer;
    use std::string::utf8;

    use aptos_framework::coin::{Self, MintCapability, BurnCapability};

    const ERR_NOT_ADMIN: u64 = 1;
    const ERR_COIN_INITIALIZED: u64 = 2;
    const ERR_COIN_NOT_INITIALZED: u64 = 3;

    struct GlowCoin{}

    struct Capabilities has key {
        mint_cap: MintCapability<GlowCoin>,
        burn_cap: BurnCapability<GlowCoin>
    }

    public entry fun initialize(admin: &signer) {
        assert!(signer::address_of(admin) == @glow_address, ERR_NOT_ADMIN);
        assert!(!coin::is_coin_initialized<GlowCoin>(), ERR_COIN_INITIALIZED);

        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<GlowCoin>(admin, utf8(b"GlowCoin"), utf8(b"GLC"), 6, true);
        coin::destroy_freeze_cap(freeze_cap);

        let caps = Capabilities {
            mint_cap,
            burn_cap
        };

        move_to(admin, caps);               
    }

    public entry fun mint(admin: &signer, to_addr: address, amount: u64) acquires Capabilities {
        assert!(signer::address_of(admin) == @glow_address, ERR_NOT_ADMIN);
        assert!(coin::is_coin_initialized<GlowCoin>(), ERR_COIN_INITIALIZED);

        let caps = borrow_global<Capabilities>(@glow_address);
        let coins = coin::mint(amount, &caps.mint_cap);
        
        coin::deposit(to_addr, coins);
    }

    public entry fun burn(user: &signer, amount: u64) acquires Capabilities {
        assert!(coin::is_coin_initialized<GlowCoin>(), ERR_COIN_INITIALIZED);

        let coin = coin::withdraw<GlowCoin>(user, amount);

        let caps = borrow_global<Capabilities>(@glow_address);

        coin::burn(coin, &caps.burn_cap);
    }

}