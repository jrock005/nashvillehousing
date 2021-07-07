/*


Cleaning Data in SQL

*/


-- Standarize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing1$;

UPDATE NashvilleHousing1$
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing1$
ADD SaleDateConverted Date;

UPDATE NashvilleHousing1$
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing1$;

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing1$
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing1$ a
	JOIN PortfolioProject.dbo.NashvilleHousing1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing1$ a
	JOIN PortfolioProject.dbo.NashvilleHousing1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Break apart Address into Individual Columns (Street Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing1$;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing1$;

ALTER TABLE NashvilleHousing1$
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing1$
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing1$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM NashvilleHousing1$;

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing1$;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing1$;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing1$
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing1$
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing1$
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing1$;

-- Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing1$
GROUP BY SoldAsVacant
ORDER BY 2 DESC;

UPDATE PortfolioProject.dbo.NashvilleHousing1$
SET SoldAsVacant = CASE
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
				   END;

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing1$
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;

DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Delete Unneeded Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing1$;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
