# BillCalFinal

This project (interview-starter) includes the bill calculation framework.
   (https://github.com/mmrobert/BillCalculation)

1. Assume discount applied before tax,
2. Discount is applied based on its priority, the largest priority is applied first,
3. The dollar discount is applied to each item proportionally to the item's price amount,
   and then modify (minus) the item price for another percentage discount,
4. You could apply a tax to multiple categories using an array of category identifiers,
5. Item are only applied with the tax which specify the item's categories,
6. At the same time, tax without categories specified are only applied to remaining items,
7. You could apply multiple tax to an item, by specifying the categories or not, but not both,
8. After you change the discount priority, enable and disable discount and tax, and toggle the item's tax exempt, 
   you have to call the method "getBillResult()" of the engine, to update the bill result,
9. The taxviewmodel is tested by using Quick/Nimble framework.
