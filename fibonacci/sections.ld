

SECTIONS
{
	ENTRY(__start)
	.text.start (0x00400000) : {
		*start_mips.o( .text )
	}

	.text : {
		*(.text)
	}

	.data : {
		*(.data)
	}

	.bss : {
		*(.bss)
	}
}

