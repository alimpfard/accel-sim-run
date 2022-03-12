import sys
from typing import List, Tuple, Iterator, Dict, Set
from pathlib import Path
from itertools import groupby
from dataclasses import dataclass
from collections import Counter


AT_LOCAL = False


def parse_one_warp(it: Iterator[str], warp_id: int) -> Iterator[Tuple[int, int, List[str], str, List[str], bool, int]]:
    for line in it:
        if line.strip() == '':
            continue
        if line.startswith('#'):
            continue
        parts = line.split(' ')
        if AT_LOCAL:
            parts = parts[4:]
        pc = int(parts[0], 16)
        flags = int(parts[1], 16)
        i = 3
        dst_regs: List[str] = []
        for x in range(int(parts[2])):
            dst_regs.append(parts[i])
            i += 1
        op = parts[i]
        i += 1
        src_regs: List[str] = []
        for x in range(int(parts[i])):
            i += 1
            src_regs.append(parts[i])
        is_memory_op = parts[i] != 0
        yield pc, flags, dst_regs, op, src_regs, is_memory_op, warp_id
        if op.lower() == 'exit':
            break


def parse_trace(it: Iterator[str]) -> Iterator[Iterator[Tuple[int, int, List[str], str, List[str], bool, int]]]:
    while True:
        try:
            line = next(it)
        except StopIteration:
            break
        if not line.startswith('warp = '):
            continue
        warp_id = int(line.split(' = ')[1])
        _ = next(it)
        yield parse_one_warp(it, warp_id)


@dataclass
class MT:
    read_count: int
    instruction: Tuple[int, int, List[str], str, List[str], bool, int]


def find_reg2mem_opportunities(it: Iterator[Tuple[int, int, List[str], str, List[str], bool, int]], seen_registers: Set[str], seen_registers_reg2mem: Set[str]) -> Iterator[Tuple[int, int, List[str], str, List[str], bool, int]]:
    # Mapping from register to read count and memory instruction
    instructions_to_consider: Dict[str, MT] = {}

    for pc, flags, dst_regs, op, src_regs, is_memory_op, warp_id in it:
        seen_registers.update(dst_regs)
        seen_registers.update(src_regs)
        seen_registers_reg2mem.update(src_regs)
        for reg, mt in instructions_to_consider.items():
            mt.read_count += sum(1 for r in dst_regs if r == reg)

        registers_overwritten_here: List[str] = []
        for reg in instructions_to_consider.keys():
            if reg in dst_regs and reg in instructions_to_consider:
                registers_overwritten_here.append(reg)

        for reg in registers_overwritten_here:
            mt = instructions_to_consider.pop(reg)
            if mt.read_count == 1:
                yield mt.instruction
            else:
                seen_registers_reg2mem.update((reg,))

        if not is_memory_op:
            seen_registers_reg2mem.update(dst_regs)
            seen_registers_reg2mem.update(src_regs)
            continue

        opcode_parts = op.lower().split('.')
        if opcode_parts[0] == 'lds':
            mt = MT(0, (pc, flags, dst_regs, op, src_regs, is_memory_op, warp_id))
            for reg in dst_regs:
                instructions_to_consider[reg] = mt

    for reg, mt in instructions_to_consider.items():
        if mt.read_count == 1:
            yield mt.instruction
        else:
            seen_registers_reg2mem.update((reg,))


def discover_kernel_traces(base_path: Path) -> Iterator[List[Path]]:
    for _, group in groupby(base_path.rglob('*.traceg'), lambda x: x.parent.parent.parent.name):
        yield list(group)


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('base_path', type=Path)
    args = parser.parse_args()
    totals = {}

    for trace_paths in discover_kernel_traces(args.base_path):
        for i, trace_path in enumerate(trace_paths):
            with open(trace_path, 'r') as f:
                print(f"Now processing {trace_path} ({i} of {len(trace_paths)} in this set) ...", file=sys.stderr)
                for it in parse_trace(f):
                    seen_regs = Counter()
                    seen_regs_with_reg2mem = Counter()
                    workload: str = trace_path.parent.parent.parent.name
                    total = totals.setdefault(workload, [Counter(), Counter()])
                    for pc, flags, dst_regs, op, src_regs, is_memory_op, warp_id in find_reg2mem_opportunities(it, seen_regs, seen_regs_with_reg2mem):
                        pass
                        # if first:
                        #     print(f'{trace_path.parent.parent.parent.name}/{trace_path.name}/{warp_id}:')
                        #     first = False
                        # print(f'    {pc:x} {flags:x} {op} ({",".join(dst_regs)}) {",".join(src_regs)}')
                    regs0 = sum(seen_regs.values())
                    regs1 = sum(seen_regs_with_reg2mem.values())
                    print(f"{workload}: Saw {len(seen_regs)} registers, could limit to {len(seen_regs_with_reg2mem)} registers")
                    print(f"{workload}: Saw {regs0} register accesses, could limit to {regs1} register accesses ({100 - regs1 / regs0 * 100:.2f}%)")
                    total[0].update(seen_regs)
                    total[1].update(seen_regs_with_reg2mem)
    for t in totals:
        ts = totals[t]
        regs0 = sum(ts[0].values())
        regs1 = sum(ts[1].values())
        print(f"In total, {t}: {regs1} / {regs0} = {100 - regs1 / regs0 * 100:.2f}%")


if __name__ == '__main__':
    main()
