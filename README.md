# WYWaterFlowLayout
&emsp;&emsp;像河流一样的布局(从上到下，从左到右的布局)。     
<img src="WYWaterFlowLayout.gif" width="300" height="514" alt="WYWaterFlowLayout.gif"/>    
    
性能测试对比（测试设备:iPhone6，数据量:10万）    

function                              |   preparLayout      |   layoutAttributesForElementsInRect        |    内存使用(1条数据的时候4.9MB)    
------------                          |   ---               |   -----------                              |    ----------                  
UICollectionViewFlowLayout            |   258.518ms         |   1.100ms                                  |    20.9MB
CHTCollectionViewWaterfallLayout      |   864.026ms         |   1.613ms                                  |    35.6MB
WYWaterFlowLayout                     |   1645.468ms        |   1.616ms                                  |    51.6MB

当然10万数据有点大  这里给个1万数据的测试    

function                              |   preparLayout      |   layoutAttributesForElementsInRect        |    内存使用    
------------                          |   ---               |   -----------                              |    ----------                
UICollectionViewFlowLayout            |   25.087ms          |   0.614ms                                  |    6.7MB
CHTCollectionViewWaterfallLayout      |   80.257ms          |   0.271ms                                  |    8.8MB
WYWaterFlowLayout                     |   160.849ms         |   0.209ms                                  |    10.3MB

