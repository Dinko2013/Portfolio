USE [TMW_STD]
GO

/****** Object:  Table [dbo].[ztbl_Tonnage_CSV_Import_Updated]    Script Date: 2017-09-21 4:16:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ztbl_DryBulkOrders](
	[ord_id] [int] IDENTITY(1,1) NOT NULL,
	[driver] [varchar](8) NULL,
	[tractor] [varchar](8) NULL,
	[trailer] [varchar](8) NULL,
	[weight] [float] NULL,
	[commodity] [varchar](8) NULL,
	[act_date] [datetime] NULL,
	[master_order] [varchar](12) NULL,
	[Carrier] [varchar](12) NULL,
	[orderno] [int] NULL,
	[import_dt] [datetime] NULL,
	[message_txt] [varchar](255) NULL,
	[transno] [varchar](50) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ztbl_Tonnage_CSV_Import_Updated] ADD  CONSTRAINT [DF_ztbl_Tonnage_CSV_Import_Updated_orderno]  DEFAULT ((0)) FOR [orderno]
GO

ALTER TABLE [dbo].[ztbl_Tonnage_CSV_Import_Updated] ADD  CONSTRAINT [DF_ztbl_Tonnage_CSV_Import_import_Updated_dt]  DEFAULT (getdate()) FOR [import_dt]
GO


