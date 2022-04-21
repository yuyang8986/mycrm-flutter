class CurrencyService{
   static  String setAmountBasedOnTrailing(String currencyTrailing, double amount) {
    switch (currencyTrailing) {
      case "":
        return amount.toStringAsFixed(1);
      case "K":
        return (amount / 1000).toStringAsFixed(1);
      case "M":
        return (amount / 1000000).toStringAsFixed(1);

      default:
        return amount.toString();
    }
  }
}