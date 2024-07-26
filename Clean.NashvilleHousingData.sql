

-- CLeaning data in SQL queries



Select *
From PortfolioProjects.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format
-- Removing 'time' from the datetime format (2015-07-17 12:34:56.000)

Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

-- SQL didnt change data so we try:

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add SaleDateConvert Date;

-- Then run query:

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- And we check the data if it changed:

Select SaleDateConverted, CONVERT(date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

-- Data has been coverted!!!






----------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress data

Select *
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

-- We are going to match equal ParcelID to NULL values that may have been linked to PropertyAddress.
-- We will use JOIN function, with ON, to link both forgein keys on same table.
-- AND function, along with UniqueID, will help us distinguish NULL values.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
-- Returns first dataset (a), with NULL values. And second dataset (b) with the correct PropertyAddress to fill in. Notice ParcelID's are same.
-- We use ISNULL function to create new table to match with values in b.ProperrtyAddress. Syntax is ISNULL(NULL table, value table)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- We will use Update function and Set function to populate NULL values

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Data has been updated!! We can check by running previous query and see it doesnt bring back ANY Null values.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID
Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
-- Elimiates commna in the PropertyAddress column. Searches: in column(PropertyAddress, first value. Charindex LOCATES comma, -1 gets rid of it.
From PortfolioProjects.dbo.NashvilleHousing

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
From PortfolioProjects.dbo.NashvilleHousing
-- We sepertated the address and city from one column into two.

-- We Execute each query one at a time

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
-- Data has been upated so we check!!

Select *
From PortfolioProjects.dbo.NashvilleHousing
-- Data has been sperated and cleaned!!! This was created using function SUBSTRING. Now let's try using PARSENAME to get rid of multipe delimiters
-- PARSENAME only takes periods out of the strings. We can the commas to periods with REPLACE function.
--- WE NEED 3 PARSENAME functions to seperate all three commas in value. Must be in DESCENDING order bc Parse does everything backwards.

Select
Parsename(REPLACE(OwnerAddress,',', '.'), 3),
Parsename(REPLACE(OwnerAddress,',', '.'), 2),
Parsename(REPLACE(OwnerAddress,',', '.'), 1)
From PortfolioProjects.dbo.NAshvilleHousing
-- Now we just create new columns and rows using  for the seperated values. We will do this by using ALTER TABLE and UPDATE functions



ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitAddress = Parsename(REPLACE(OwnerAddress,',', '.'), 3)



ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitAddress = Parsename(REPLACE(OwnerAddress,',', '.'), 2)



ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitState = Parsename(REPLACE(OwnerAddress,',', '.'), 1)
-- Now we check our dataset for the newly created columns.

Select *
From PortfolioProjects.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold AS Vacant" field
-- This query helps us find each distinct vaules used in this column and and how many.

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


-- Next we create Scenarios for SQL: WHEN(SoldAsVacant) = 'Y' THEN 'Yes'
Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsvacant
		END
From PortfolioProjects.dbo.NashvilleHousing


-- Now we use our Scenario in the UPDATE, SET functions:
Update PortfolioProjects.dbo.NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsvacant
		END



------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove duplicates
-- Not a standard practice to delete data from a dataset, we might need later on!!! Nevertheless, this is how:

Select *,
ROW_NUMBER() OVER(
Partition By ParcelID,
			PropertyAddress,
			LegalReference,
			SalePrice,
			SaleDate
			ORDER By
				UniqueID
				) row_num
From PortfolioProjects.dbo.NashvilleHousing
Order By ParcelID
-- Now we will use this row_num query and insert it into a CTE function: WITH (new_name) AS(
--																		 Select*,ROW_NUMBER() OVER()
--																		 FROM ...
--																		 )


With RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(
Partition By ParcelID,
			PropertyAddress,
			LegalReference,
			SalePrice,
			SaleDate
			ORDER By
				UniqueID
				) row_num
From PortfolioProjects.dbo.NashvilleHousing
)
Select*
From RowNumCTE
where row_num > 1
Order By PropertyAddress
-- There is 104 duplicate rows, so to delete them we will change the SELECT function into DELETE and get rid of ORDER BY function as well.

With RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(
Partition By ParcelID,
			PropertyAddress,
			LegalReference,
			SalePrice,
			SaleDate
			ORDER By
				UniqueID
				) row_num
From PortfolioProjects.dbo.NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1
-- Rows have been deleted. Now we check:

With RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(
Partition By ParcelID,
			PropertyAddress,
			LegalReference,
			SalePrice,
			SaleDate
			ORDER By
				UniqueID
				) row_num
From PortfolioProjects.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1
-- Query find zero duplicates!!!




-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Deleting data is not recommended, we might need the data later on!!!
-- We will use ALTER TABLE and DROP COLUNM functions

Select *
From PortfolioProjects.dbo.NashvilleHousing


Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict


----------------------------------------------------------------------------------------------------------------------------------------------------------

