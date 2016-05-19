function Out-MrSpeech {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string]$Phrase
    )

    Add-Type -AssemblyName System.Speech

    $voice = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer

    $voice.Speak($Phrase)

}