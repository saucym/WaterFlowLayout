# WYWaterFlowLayout
&emsp;&emsp;像河流一样的布局(从上到下，从左到右的布局)。     
<img src="WYWaterFlowLayout.gif" width="300" height="514" alt="WYWaterFlowLayout.gif"/>    
    
性能测试对比（测试设备:iPhone6，数据量:10万）    

function                              |   preparLayout      |   layoutAttributesForElementsInRect        |    内存使用(1条数据的时候4.9MB)    
------------                          |   ---               |   -----------                              |    ----------                  
UICollectionViewFlowLayout            |   258.518 ms        |   1.100 ms                                 |    20.9 MB
CHTCollectionViewWaterfallLayout      |   864.026 ms        |   1.613 ms                                 |    35.6 MB
WYWaterFlowLayout                     |   1076.112 ms       |   1.776 ms                                 |    50.4 MB

当然10万数据有点大  这里给个1万数据的测试    

function                              |   preparLayout      |   layoutAttributesForElementsInRect        |    内存使用    
------------                          |   ---               |   -----------                              |    ----------                
UICollectionViewFlowLayout            |   25.087 ms         |   0.614 ms                                 |    6.7 MB
CHTCollectionViewWaterfallLayout      |   80.257 ms         |   0.271 ms                                 |    8.8 MB
WYWaterFlowLayout                     |   98.604 ms         |   0.246 ms                                 |    10.4 MB


License
-------
WYWaterFlowLayout is available under the MIT license. See the LICENSE file for more info.
