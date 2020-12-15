import java.io.File
import java.math.BigInteger


enum class Bit {
    ON, OFF, FLOATING
}

open class FerryInstruction
data class Mask(val value: Map<Int, Bit>): FerryInstruction()
data class MemoryAllocation(val address: Long, val value: Long): FerryInstruction()

data class ComputerState(val mask: Mask, val memory: MutableMap<Long, Long>) {
    fun memorySum(): Long {
        return memory
            .values
            .sum()
    }
}


fun initializeComputerState(): ComputerState {
    return ComputerState(Mask(emptyMap()), mutableMapOf<Long, Long>())
}

fun main() {
    val memorySumVersion1 = loadInstructions("input.txt")
        .fold(initializeComputerState(), ::executeFerryInstruction)
        .memorySum()
        
    println(memorySumVersion1)    

    val memorySumVersion2 = loadInstructions("input.txt")
        .fold(initializeComputerState(), ::executeFerryInstructionVersion2)
        .memorySum()

    println(memorySumVersion2)
}

fun loadInstructions(filename: String): Sequence<FerryInstruction> {
    return  File(filename)
        .bufferedReader()
        .lineSequence()
        .map(::transformData)
}

fun executeFerryInstruction(acc: ComputerState, instruction: FerryInstruction): ComputerState {
    when (instruction) {
        is Mask -> return ComputerState(instruction, acc.memory)
        is MemoryAllocation -> {
            val value = applyMaskToValue(acc.mask, instruction.value)
            acc.memory[instruction.address] = value
            return acc
        }
    }
    return acc
}

fun executeFerryInstructionVersion2(acc: ComputerState, instruction: FerryInstruction): ComputerState {
    when (instruction) {
        is Mask -> return ComputerState(instruction, acc.memory)
        is MemoryAllocation -> {
            for (address in applyMaskToAddress(acc.mask, instruction.address)) {
                acc.memory[address] = instruction.value
            }
            return acc
        }
    }
    return acc
}

fun pow(n: Long, exp: Int): Long{
    return BigInteger.valueOf(n).pow(exp).toLong()
}

fun applyMaskToValue(mask: Mask, value: Long): Long {
    var number = value
    for ((i, v) in mask.value.entries) {
        when (v) {
            Bit.ON -> { number = number or pow(2, i) }
            Bit.OFF -> { number = number and pow(2, i).inv() }
            else -> {}
        }
    }
    return number
}

fun applyMaskToAddress(mask: Mask, address: Long): List<Long> {
    var addresses = listOf(address)
    for ((index, bit) in mask.value.entries) {
        addresses = addresses
            .map { applyBitToAddress(index, bit, it) }
            .flatten()
    }
    return addresses
}

fun applyBitToAddress(index: Int, bit: Bit, address: Long): List<Long> {
    return when (bit) {
        Bit.ON -> listOf(address or pow(2, index))
        Bit.FLOATING -> listOf(address or pow(2, index), address and pow(2, index).inv())
        else -> listOf(address)
    }
}

val memoryRegex = Regex("""^mem\[(\d+)\] = (\d+)$""")
val maskRegex = Regex("""^mask = ([01X]{36})$""")
val bitMapping = mapOf('0' to Bit.OFF, '1' to Bit.ON, 'X' to Bit.FLOATING)

fun transformData(line: String): FerryInstruction {
    val memoryMatch = memoryRegex.matchEntire(line)
    memoryMatch?.let {
        val (address, value) = memoryMatch.destructured
        return MemoryAllocation(address.toLong(), value.toLong())
    }

    val maskMatch = maskRegex.matchEntire(line)
    maskMatch?.let {
        val (stringValue) = maskMatch.destructured
        val value = stringValue
            .toList()
            .asReversed()
            .withIndex()
            .map {(i, value) -> Pair(i, bitMapping[value]!!) }
            .toMap()
        
        return Mask(value)
    }

    throw Exception("Unexpected data")
}
