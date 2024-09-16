struct multiboot_system_table{ // 系统表结构
	uint32 flags;
	// 内存信息
	uint32 memory_lower;
	uint32 memory_upper; // 重点关注这个1MB以上内存大小 单位KB
	// 启动设备
	uint32 boot_device;
	// 命令行参数指针
	uint32 command_line;
	// 模块信息
	uint32 mods_count;
	uint32 mods_addr;
	// 内核映像符号表
	uint32 syms_table_size;
	uint32 syms_string_size;
	uint32 syms_table_address;
	uint32 syms_reserved;
	// 内存分布信息
	uint32 memory_map_length;
	uint32 memory_map_address;
	// 驱动器信息
	uint32 drives_length;
	uint32 drives_address;
	// 配置表指针
	uint32 config_table;
	// 引导程序名指针
	uint32 boot_loader_name;
	// APM表指针
	uint32 apm_table;
	// VBE表
	uint32 vbe_control_information;
	uint32 vbe_mode_information; // BIOS中断10H功能号4F01H的返回结构指针
	uint16 vbe_mode;
	uint16 vbe_interface_segment; // VBE保护模式接口信息
	uint16 vbe_interface_offset;
	uint16 vbe_interface_length;
};
