// AnimatedContainer(
//                                 duration: const Duration(milliseconds: 300),
//                                 margin: EdgeInsets.symmetric(
//                                     horizontal: 10.w, vertical: 8.h),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.grey[900]!.withOpacity(0.95),
//                                       Colors.grey[850]!.withOpacity(0.95),
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(16.r),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.15),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                   border: Border.all(
//                                     color: Colors.grey[800]!,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(20.r),
//                                   child: BackdropFilter(
//                                     filter:
//                                         ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//                                     child: Container(
//                                       padding: EdgeInsets.all(20.r),
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             Colors.white.withOpacity(0.05),
//                                             Colors.white.withOpacity(0.02),
//                                           ],
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                         ),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Trade Header with enhanced styling
//                                           _buildTradeHeader(
//                                             qnty: activeTradeEntity
//                                                 .record![index].dataRelatedTo
//                                                 .toString(),
//                                             date: activeTradeEntity
//                                                 .record![index].currentDate
//                                                 .toString(),
//                                             time: activeTradeEntity
//                                                 .record![index].time
//                                                 .toString(),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 activeTradeEntity
//                                                     .record![index].symbolName
//                                                     .toString(),
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 15.sp,
//                                                   fontWeight: FontWeight.w500,
//                                                   letterSpacing: 0.5,
//                                                 ),
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     '${activeTradeEntity.record![index].orderMethod}: ',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       color: activeTradeEntity
//                                                                   .record![
//                                                                       index]
//                                                                   .orderMethod ==
//                                                               'Sale'
//                                                           ? Colors.red
//                                                           : Colors.green,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     '${activeTradeEntity.record![index].availableQty} @ ${activeTradeEntity.record![index].stockPrice}',
//                                                     style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                       color: Colors.white,
//                                                     ),
//                                                   )
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                           // Trade Details with modern layout
//                                           _buildTradeDetails(
//                                               // symbolName: activeTradeEntity
//                                               //     .record![index].symbolName
//                                               //     .toString(),
//                                               // symbolPrice: activeTradeEntity
//                                               //     .record![index].stockPrice!
//                                               //     .toDouble(),
//                                               margin: activeTradeEntity
//                                                   .record![index].margin
//                                                   .toString(),
//                                               marginHolding: activeTradeEntity
//                                                   .record![index].marginHolding
//                                                   .toString(),
//                                               mathod: activeTradeEntity
//                                                   .record![index].orderMethod
//                                                   .toString(),
//                                               category: activeTradeEntity
//                                                   .record![index].dataRelatedTo
//                                                   .toString()),
//                                           SizedBox(height: 20.h),
//                                           // Close trade button with modern design
//                                           BlocConsumer(
//                                             listener: (context, state) {
//                                               if (state is HomeLoadingState ||
//                                                   state is HomeLoadingState2) {
//                                                 setState(() {
//                                                   loadingIndices
//                                                       .clear(); // Clear loading state when operation completes
//                                                 });
//                                               }
//                                             },
//                                             bloc: _homeBloc,
//                                             builder: (context, state) {
//                                               return Container(
//                                                 width: double.infinity,
//                                                 height: 50.h,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.grey.shade700,
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           12.r),
//                                                 ),
//                                                 child: Material(
//                                                   color: Colors.transparent,
//                                                   child: InkWell(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12.r),
//                                                     onTap:
//                                                         loadingIndices
//                                                                 .contains(index)
//                                                             ? null
//                                                             : () async {
//                                                                 setState(() {
//                                                                   loadingIndices
//                                                                       .add(
//                                                                           index); // Add loading state for this specific button
//                                                                 });

//                                                                 try {
//                                                                   final getData = await TradeRepository.getStockRecords(
//                                                                       activeTradeEntity
//                                                                           .record![
//                                                                               index]
//                                                                           .symbolKey
//                                                                           .toString(),
//                                                                       activeTradeEntity
//                                                                           .record![
//                                                                               index]
//                                                                           .dataRelatedTo
//                                                                           .toString());

//                                                                   if (!mounted)
//                                                                     return;

//                                                                   // Calculate canBuy using first item from response
//                                                                   dynamic
//                                                                       canBuy =
//                                                                       0.0;
//                                                                   if (getData
//                                                                       .response
//                                                                       .isNotEmpty) {
//                                                                     final price = activeTradeEntity.record![index].tradeMethod ==
//                                                                             1
//                                                                         ? getData
//                                                                             .response[
//                                                                                 0]
//                                                                             .ohlc
//                                                                             .buyPrice
//                                                                         : getData
//                                                                             .response[0]
//                                                                             .ohlc
//                                                                             .salePrice;
//                                                                     canBuy = price *
//                                                                         double.parse(activeTradeEntity
//                                                                             .record![index]
//                                                                             .availableQty
//                                                                             .toString());
//                                                                   }

//                                                                   final double
//                                                                       parsedUBalance =
//                                                                       uBalance
//                                                                               is String
//                                                                           ? double.tryParse(uBalance) ??
//                                                                               0.0
//                                                                           : (uBalance ??
//                                                                               0.0);

//                                                                   if (canBuy >
//                                                                       parsedUBalance) {
//                                                                     setState(
//                                                                         () {
//                                                                       loadingIndices
//                                                                           .remove(
//                                                                               index);
//                                                                     });
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder:
//                                                                           (context) =>
//                                                                               const WarningAlertBox(
//                                                                         title:
//                                                                             'Warning',
//                                                                         message:
//                                                                             'You Cant Sale Stock Your Balance is Low!',
//                                                                       ),
//                                                                     );
//                                                                   } else {
//                                                                     if (activeTradeEntity
//                                                                             .record![index]
//                                                                             .tradeMethod ==
//                                                                         1) {
//                                                                       _homeBloc.add(
//                                                                           SaleStocksEvent(
//                                                                         symbolKey: activeTradeEntity
//                                                                             .record![index]
//                                                                             .symbolKey
//                                                                             .toString(),
//                                                                         categoryName: activeTradeEntity
//                                                                             .record![index]
//                                                                             .dataRelatedTo
//                                                                             .toString(),
//                                                                         context:
//                                                                             context,
//                                                                         stockPrice: getData
//                                                                             .response[0]
//                                                                             .ohlc
//                                                                             .buyPrice
//                                                                             .toString(),
//                                                                         stockQty: activeTradeEntity
//                                                                             .record![index]
//                                                                             .availableQty
//                                                                             .toString(),
//                                                                       ));
//                                                                       _tradeBloc.add(ActiveStockTradeEvent(
//                                                                           activity:
//                                                                               'active-stock'));
//                                                                     } else {
//                                                                       _homeBloc.add(
//                                                                           BuyStocksEvent(
//                                                                         symbolKey: activeTradeEntity
//                                                                             .record![index]
//                                                                             .symbolKey
//                                                                             .toString(),
//                                                                         categoryName: activeTradeEntity
//                                                                             .record![index]
//                                                                             .dataRelatedTo
//                                                                             .toString(),
//                                                                         context:
//                                                                             context,
//                                                                         stockPrice: getData
//                                                                             .response[0]
//                                                                             .ohlc
//                                                                             .salePrice
//                                                                             .toString(),
//                                                                         stockQty: activeTradeEntity
//                                                                             .record![index]
//                                                                             .availableQty
//                                                                             .toString(),
//                                                                       ));
//                                                                       _tradeBloc.add(ActiveStockTradeEvent(
//                                                                           activity:
//                                                                               'active-stock'));
//                                                                     }
//                                                                   }
//                                                                 } catch (e) {
//                                                                   setState(() {
//                                                                     loadingIndices
//                                                                         .remove(
//                                                                             index);
//                                                                   });
//                                                                   ScaffoldMessenger.of(
//                                                                           context)
//                                                                       .showSnackBar(
//                                                                     SnackBar(
//                                                                         content:
//                                                                             Text('Error: $e')),
//                                                                   );
//                                                                 }
//                                                               },
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         if (loadingIndices
//                                                             .contains(index))
//                                                           const SizedBox(
//                                                             width: 20,
//                                                             height: 20,
//                                                             child:
//                                                                 CircularProgressIndicator(
//                                                               valueColor:
//                                                                   AlwaysStoppedAnimation<
//                                                                           Color>(
//                                                                       Colors
//                                                                           .white),
//                                                               strokeWidth: 2,
//                                                             ),
//                                                           )
//                                                         else
//                                                           Icon(Icons.close,
//                                                               size: 20.r,
//                                                               color:
//                                                                   Colors.white),
//                                                         SizedBox(width: 10.w),
//                                                         Text(
//                                                           loadingIndices
//                                                                   .contains(
//                                                                       index)
//                                                               ? 'PROCESSING...'
//                                                               : 'CLOSE TRADE',
//                                                           style: TextStyle(
//                                                             fontSize: 15.sp,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             color: Colors.white,
//                                                             letterSpacing: 0.5,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
