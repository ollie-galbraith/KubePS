Function ConvertTo-KubePSResourceNumber
    {
        <#
        .SYNOPSIS
            Converts Kubernetes resource quantities such as milli-CPU, memory values, and SI/IEC suffixes into a decimal number that can be used for math and percentage calculations.
            This helper normalizes values like "250m", "512Mi", "1Gi", or "500m" into a common base unit so KubePS can compare requests, limits, and allocatable totals across CPU and memory metrics.

        .EXAMPLE
            ConvertTo-KubePSResourceNumber -Quantity '250m'
            # Returns 0.25, which is useful for CPU calculations.

        .EXAMPLE
            ConvertTo-KubePSResourceNumber -Quantity '1Gi'
            # Returns 1073741824, which is the byte-equivalent for a 1 GiB allocation.
        #>
        param(
            [Parameter(Mandatory=$True)]
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