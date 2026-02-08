1. 请通过connect_server连接到linux服务器，直接在cmd敲入connect_server即可进入linxu服务器，探索~/.tcshrc找到jaspergold工具
2. 分析/home/yezhihui/Projects/agent_demo下的spi verilog rtl代码
3. 根据verilog rtl代码生成formal property，然后通过bind连接到对应rtl，相应文件放在/home/yezhihui/Projects/agent_demo/spi_tb/property下
4. 使用jaspergold fpv&cov app对spi进行formal验证，formal相关tcl脚本放在/home/yezhihui/Projects/agent_demo/spi_tb，脚本需要
   集成到/home/yezhihui/Projects/agent_demo/spi_tb/Makefile
5. 通过fpv app使得所有property 结果为proven，遇到property证明结果为inconclusive，undetermined，自行找方案解决
6. 使用cov app对formal验证进行覆盖率收集，
7. 请把formal coverage，stimuli coverage，checker coverage这几
   类覆盖率数据通过tcl导出到文件，并分析未覆盖点，看是否需要加property或wave，以达到这几类覆盖率数据达到100%,以达到sign off标准，
8. 尽量少的人工互动，自行解决遇到所有问题