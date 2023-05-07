/*

Cleaning Data

*/

SELECT *
FROM
	PortfolioProjects.dbo.NashvilleHousing

--1. Converting SaleDate column type into Date

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date
----------------------------------------------------------------------------------------------------------------------------------------

--2. Populate Property Address data
--29 cells is null
SELECT *
FROM
	PortfolioProjects.dbo.NashvilleHousing
WHERE
	PropertyAddress IS NULL


SELECT
	[UniqueID ],
	ParcelID,
	PropertyAddress
FROM
	PortfolioProjects.dbo.NashvilleHousing
ORDER BY 2


SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress
FROM
	PortfolioProjects.dbo.NashvilleHousing a
INNER JOIN 
	PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL

--(29 rows affected)
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
	PortfolioProjects.dbo.NashvilleHousing a
INNER JOIN 
	PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL
----------------------------------------------------------------------------------------------------------------------------------------

--3. Breaking out PropertyAddress into Individual Columns (Address, City)
-- Adding new column "Property_Address" by spliting the PropertyAddress column 
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD Property_Address Nvarchar(100)

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- Adding new column "Property_City" by spliting the PropertyAddress column 
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD Property_City Nvarchar(100)

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
----------------------------------------------------------------------------------------------------------------------------------------

--4. Breaking out OwnerAddress into Individual Columns (Address, City, State)
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM
	PortfolioProjects.dbo.NashvilleHousing

-- Adding new column "Owner_Address" by spliting the OwnerAddress column
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD Owner_Address Nvarchar(100)

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Adding new column "Owner_City" by spliting the OwnerAddress column 
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD Owner_City Nvarchar(100)

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Adding new column "Owner_State" by spliting the OwnerAddress column
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD Owner_State Nvarchar(100)

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
----------------------------------------------------------------------------------------------------------------------------------------

--5. Change Y and N to Yes and No in "SoldAsVacant" field
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	PortfolioProjects.dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
--As the field have N, No, Y and Yes , I will make it Yes and No only
SELECT
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END 
FROM
	PortfolioProjects.dbo.NashvilleHousing

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
----------------------------------------------------------------------------------------------------------------------------------------

--6. Removing Duplicates
--(104 rows affected)
WITH RowNum_CTE AS 
(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY  ParcelID,
				   PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   ORDER BY UniqueID) Row_Number 
FROM
	PortfolioProjects.dbo.NashvilleHousing
) 
DELETE
FROM
	RowNum_CTE
WHERE
	Row_Number >1
----------------------------------------------------------------------------------------------------------------------------------------

--7. Delete Unused Columns

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
