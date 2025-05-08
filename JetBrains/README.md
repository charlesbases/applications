## [goland](./GoLand)

- ##### Help

  - ##### .vmoptions

    ```
    -Xms2048m
    -Xmx8192m
    -XX:ReservedCodeCacheSize=1024m
    -XX:+UseG1GC
    ```

    

  - idea.properties
  
    ```shell
    # Error: (DEBUG) undefined behavior - version of Delve is too old for Go version 1.20 (manimum supported version 1.18)
    # dlv 版本过低
    
    # go install github.com/go-delve/delve/cmd/dlv@latest
    # assign dlv path or move move dlv to JetBrains
    # windows: 'D:\JetBrains\GoLand\plugins\go\lib\dlv\windows'
    dlv.path=E:\\Program\\bin\\dlv.exe
    
    # filesize
    idea.max.intellisense.filesize=1024000
    ```
  
  - ##### pty
  
    ```shell
    # Error: 
    #   (Terminal) 文字丢失
    #   Run 乱码
    
    # disable pty
    # 路径：Help -> Find Action -> Registry -> go.run.procesess.with.pty -> disable
    ```
    
  
- Plugins

  ```shell
  # Json Parser
  # Protobuf
  ```
  
- Live Templates

  ```shell
  # name_test.go => Name
  capitalize(substringBefore(fileNameWithoutExtension(), "_"))
  ```

  

---

## [pycharm](./PyCharm)



------

## [datagrip](./DataGrip)

---

## [rider](./Rider)
