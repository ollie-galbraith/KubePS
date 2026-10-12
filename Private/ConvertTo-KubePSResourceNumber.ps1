Function ConvertTo-KubePSResourceNumber
    {
        param(
            [string]$Quantity
        )

        If([string]::IsNullOrWhiteSpace($Quantity))
            {
                Return [decimal]0
            }
        If($Quantity -match '^([0-9]+(?:\.[0-9]+)?)(n|u|m)$')
            {
                $Scale = @{ n = [decimal]0.000000001; u = [decimal]0.000001; m = [decimal]0.001 }
                Return [decimal]$Matches[1] * $Scale[$Matches[2]]
            }
        If($Quantity -match '^([0-9]+(?:\.[0-9]+)?)(Ki|Mi|Gi|Ti|Pi|Ei|K|M|G|T|P|E)?$')
            {
                $Scale = @{ Ki = 1KB; Mi = 1MB; Gi = 1GB; Ti = 1TB; Pi = [decimal]1125899906842624; Ei = [decimal]1152921504606846976; K = 1000; M = 1000000; G = 1000000000; T = 1000000000000; P = 1000000000000000; E = [decimal]1000000000000000000 }
                $Multiplier = If($Matches[2]) { $Scale[$Matches[2]] } Else { 1 }
                Return [decimal]$Matches[1] * $Multiplier
            }
        Return [decimal]0
    }