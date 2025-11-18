class TronSwapConstants {
  // SunSwap V2 Router Addresses
  static const String routerMainnet = 'TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax';
  static const String routerNile = 'TDAQGC5Ekd683GjekSaLzCaeg7jGsGSmbh';
  static const String routerShasta = 'TDAQGC5Ekd683GjekSaLzCaeg7jGsGSmbh'; // Same as Nile for testnets
  
  // SunSwap V2 Factory Addresses
  static const String factoryMainnet = 'TKWJdrQkqHisa1X8HUdHEfREvTzw4pMAaY';
  
  // Common TRC20 Tokens on Testnet (Shasta/Nile)
  static const String usdtNile = 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf';
  static const String usdjNile = 'TLBaRhANQoJFTqre9Nf1mjuwNWjCJeYqUL';
  
  // Mainnet tokens
  static const String usdtMainnet = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';
  static const String usdcMainnet = 'TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8';
  
  // Swap deadline (10 minutes from now)
  static int get deadline => DateTime.now().millisecondsSinceEpoch ~/ 1000 + 600;
  
  // Default slippage tolerance (0.5%)
  static const double defaultSlippage = 0.5;
  
  // Minimum amount for swap (0.01 TRX)
  static const int minimumSwapAmount = 10000; // in sun (1 TRX = 1,000,000 sun)
}
