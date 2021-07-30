# NoiseMeasuringTool

Use for iOS to measure Noise level in dB.

# Usage

1. init  NoiseMeasuringTool and set delegate 

    ```markdown
    let dbTool:NoiseMeasuringTool = NoiseMeasuringTool.init()

    dbTool.delegate = self
    ```

2. Start measuring

    ```markdown
    dbTool.startMeasuring()
    ```

3. Get result 

    ```markdown
    func audioPowerChanged(tool:NoiseMeasuringTool, db:Float){
        print(db)
        print(tool.powerPercentage)
    }
    ```

4. Stop measuring 

    ```markdown
    dbTool.stopMeasuring()
    ```
